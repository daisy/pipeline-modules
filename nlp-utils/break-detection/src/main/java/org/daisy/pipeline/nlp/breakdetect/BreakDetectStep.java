package org.daisy.pipeline.nlp.breakdetect;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.nlp.lexing.LexService;
import org.daisy.pipeline.nlp.lexing.LexService.LexerInitException;
import org.daisy.pipeline.nlp.lexing.LexServiceRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

/**
 * XprocStep built on the top of a Lexer meant to be provided by an OSGI service
 * through BreakDetectProvider.
 */
public class BreakDetectStep extends DefaultStep implements TreeWriterFactory,
        InlineSectionProcessor {

	private Logger mLogger = LoggerFactory.getLogger(BreakDetectStep.class);
	private ReadablePipe mSource = null;
	private WritablePipe mResult = null;
	private XProcRuntime mRuntime = null;
	private LexServiceRegistry mLexerRegistry;
	private Set<Locale> mLangs;

	private Collection<String> inlineTagsOption;
	private Collection<String> commaTagsOption;
	private Collection<String> spaceTagsOption;
	private String tmpNs;
	private String wordTagOption;
	private String sentenceTagOption;

	public BreakDetectStep(XProcRuntime runtime, XAtomicStep step, LexServiceRegistry registry) {
		super(runtime, step);
		mRuntime = runtime;
		mLexerRegistry = registry;
	}

	// This constructor is provided so that it is compliant with vanilla Calabash
	public BreakDetectStep(XProcRuntime runtime, XAtomicStep step) {
		this(runtime, step, null);
	}

	public void setInput(String port, ReadablePipe pipe) {
		if ("source".equals(port)) {
			mSource = pipe;
		}
	}

	@Override
	public void setOption(QName name, RuntimeValue value) {
		super.setOption(name, value);
		if ("inline-tags".equalsIgnoreCase(name.getLocalName())) {
			inlineTagsOption = processListOption(value.getString());
		} else if ("comma-tags".equalsIgnoreCase(name.getLocalName())) {
			commaTagsOption = processListOption(value.getString());
		} else if ("space-tags".equalsIgnoreCase(name.getLocalName())) {
			spaceTagsOption = processListOption(value.getString());
		} else if ("output-word-tag".equalsIgnoreCase(name.getLocalName())) {
			wordTagOption = value.getString();
		} else if ("output-sentence-tag".equalsIgnoreCase(name.getLocalName())) {
			sentenceTagOption = value.getString();
		} else if ("tmp-ns".equalsIgnoreCase(name.getLocalName())) {
			tmpNs = value.getString();
		} else {
			runtime.error(new RuntimeException("unrecognized option " + name));
		}
	}

	public void setOutput(String port, WritablePipe pipe) {
		mResult = pipe;
	}

	public void reset() {
		mSource.resetReader();
		mResult.resetWriter();
	}

	static private Collection<String> processListOption(String opt) {
		return Arrays.asList(opt.split(","));
	}

	public void run() throws SaxonApiException {
		super.run();

		//Retrieve a generic lexer that can handle unexpected languages.
		//Unexpected languages could happen if the detected languages in
		//XmlBreakRebuilder are not the same as the ones detected in this class.
		HashMap<Locale, LexService> langToLexers = new HashMap<Locale, LexService>();
		LexService generic = mLexerRegistry.getBestGenericLexService();
		try {
			generic.init();
		} catch (LexerInitException e1) {
			mRuntime.error(e1);
			return;
		}
		langToLexers.put(null, generic);

		FormatSpecifications formatSpecs = new FormatSpecifications(tmpNs, sentenceTagOption,
		        wordTagOption, "http://www.w3.org/XML/1998/namespace", "lang",
		        inlineTagsOption, commaTagsOption, spaceTagsOption);

		XmlBreakRebuilder xmlRebuilder = new XmlBreakRebuilder();

		long before = System.currentTimeMillis();

		while (mSource.moreDocuments()) {
			XdmNode doc = mSource.read();

			//init the lexers with the languages
			mLangs = new HashSet<Locale>();
			try {
				new InlineSectionFinder().find(doc, 0, formatSpecs, this,
				        Collections.EMPTY_SET);
				for (Locale lang : mLangs) {
					if (!langToLexers.containsKey(lang)) {
						LexService lexer = mLexerRegistry.getLexerForLanguage(lang,
						        langToLexers.values());
						if (lexer == null) {
							throw new LexerInitException(
							        "cannot find a lexer for the language: " + lang);
						}
						if (!langToLexers.containsValue(lexer))
							lexer.init();
						langToLexers.put(lang, lexer);
					}
				}
			} catch (LexerInitException e) {
				mRuntime.error(e);
				continue;
			}

			mRuntime.info(null, null, "Total number of language(s): "
			        + (langToLexers.size() - 1));
			for (Map.Entry<Locale, LexService> entry : langToLexers.entrySet()) {
				mRuntime.info(null, null, "LexService for language '"
				        + (entry.getKey() == null ? "<ANY>" : entry.getKey()) + "': "
				        + entry.getValue().getName());
			}

			//rebuild the XML tree and lex the content on-the-fly
			XdmNode tree;
			try {
				tree = xmlRebuilder.rebuild(this, langToLexers, doc, formatSpecs);
				mResult.write(tree);
			} catch (LexerInitException e) {
				mRuntime.error(e);
			}
		}

		long after = System.currentTimeMillis();
		mLogger.debug("lexing time = " + (after - before) / 1000.0 + " s.");

		for (LexService lexer : langToLexers.values()) {
			lexer.cleanUpLangResources();
		}

		mLangs = null;
	}

	@Override
	public TreeWriter newInstance() {
		return new TreeWriter(mRuntime);
	}

	@Override
	public void onInlineSectionFound(List<Leaf> leaves, List<String> text, Locale lang)
	        throws LexerInitException {

		//TODO: insert the language detection here. Another language detection
		//might be needed in XmlBreakRebuilder as well.
		if (lang != null) {
			mLangs.add(lang);
		}
	}

	@Override
	public void onEmptySectionFound(List<Leaf> leaves) {

	}
}
