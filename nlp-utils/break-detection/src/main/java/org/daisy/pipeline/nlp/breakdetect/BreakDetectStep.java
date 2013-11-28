package org.daisy.pipeline.nlp.breakdetect;

import java.util.Arrays;
import java.util.Collection;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.nlp.lexing.LexService;
import org.daisy.pipeline.nlp.lexing.LexService.LexerInitException;
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
public class BreakDetectStep extends DefaultStep implements TreeWriterFactory {

	private Logger mLogger = LoggerFactory.getLogger(BreakDetectStep.class);
	private ReadablePipe mSource = null;
	private WritablePipe mResult = null;
	private XProcRuntime mRuntime = null;
	private LexService mLexer;

	private Collection<String> inlineTagsOption;
	private Collection<String> commaTagsOption;
	private Collection<String> spaceTagsOption;
	private String tmpNs;
	private String wordTagOption;
	private String sentenceTagOption;

	public BreakDetectStep(XProcRuntime runtime, XAtomicStep step,
	        LexService lexer) {
		super(runtime, step);
		mRuntime = runtime;
		mLexer = lexer;
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

		try {
			mLexer.init();
		} catch (LexerInitException e) {
			mRuntime.error(e);
		}

		FormatSpecifications formatSpecs = new FormatSpecifications(tmpNs,
		        sentenceTagOption, wordTagOption,
		        "http://www.w3.org/XML/1998/namespace", "lang",
		        inlineTagsOption, commaTagsOption, spaceTagsOption);

		XmlBreakRebuilder xmlRebuilder = new XmlBreakRebuilder();

		long before = System.currentTimeMillis();

		while (mSource.moreDocuments()) {
			XdmNode doc = mSource.read();
			XdmNode tree;
			try {
				tree = xmlRebuilder.rebuild(this, mLexer, doc, formatSpecs);
				mResult.write(tree);
			} catch (LexerInitException e) {
				mRuntime.error(e);
			}
		}

		long after = System.currentTimeMillis();
		mLogger.debug("lexing time = " + (after - before) / 1000.0 + " s.");

		mLexer.cleanUpLangResources();
	}

	@Override
	public TreeWriter newInstance() {
		return new TreeWriter(mRuntime);
	}
}
