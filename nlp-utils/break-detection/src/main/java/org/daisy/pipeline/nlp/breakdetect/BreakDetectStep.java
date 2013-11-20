package org.daisy.pipeline.nlp.breakdetect;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmNodeKind;
import net.sf.saxon.s9api.XdmSequenceIterator;

import org.daisy.pipeline.nlp.lexing.LexService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;

/**
 * XprocStep built on the top of a Lexer meant to be provided by an OSGI service
 * through BreakDetectProvider.
 */
public class BreakDetectStep extends DefaultStep {

	private Logger mLogger = LoggerFactory.getLogger(BreakDetectStep.class);
	private XmlBreakRebuilder mXmlRebuilder;
	private ReadablePipe mSource = null;
	private WritablePipe mResult = null;

	private Collection<String> inlineTagsOption;
	private Collection<String> commaTagsOption;
	private Collection<String> spaceTagsOption;
	private Collection<String> fullstopTagsOption;
	private String tmpNs;
	private String wordTagOption;
	private String sentenceTagOption;
	private String mergeableAttrOption;
	private FormatSpecifications mFormatSpecs;

	public BreakDetectStep(XProcRuntime runtime, XAtomicStep step,
	        LexService lexer) {
		super(runtime, step);
		mXmlRebuilder = new XmlBreakRebuilder(runtime, lexer);
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
		} else if ("end-sentence-tags".equalsIgnoreCase(name.getLocalName())) {
			fullstopTagsOption = processListOption(value.getString());
		} else if ("space-tags".equalsIgnoreCase(name.getLocalName())) {
			spaceTagsOption = processListOption(value.getString());
		} else if ("output-word-tag".equalsIgnoreCase(name.getLocalName())) {
			wordTagOption = value.getString();
		} else if ("output-sentence-tag".equalsIgnoreCase(name.getLocalName())) {
			sentenceTagOption = value.getString();
		} else if ("tmp-ns".equalsIgnoreCase(name.getLocalName())) {
			tmpNs = value.getString();
		} else if ("mergeable-attr".equalsIgnoreCase(name.getLocalName())) {
			mergeableAttrOption = value.getString();
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

	/**
	 * Traverse recursively the whole tree to find the inline sections of the
	 * document.
	 */
	private boolean findInlineSections(XdmNode node,
	        HashSet<XdmNode> inlineSections) {
		XdmSequenceIterator iter = node.axisIterator(Axis.CHILD);
		boolean isInlineSection = node.getNodeKind() == XdmNodeKind.TEXT
		        || (node.getNodeName() != null && mFormatSpecs.inlineElements
		                .contains(node.getNodeName().getLocalName()));
		while (iter.hasNext()) {
			XdmNode child = (XdmNode) iter.next();
			boolean r = findInlineSections(child, inlineSections);
			isInlineSection &= r;
		}
		if (isInlineSection)
			inlineSections.add(node);

		return isInlineSection;
	}

	static private Collection<String> processListOption(String opt) {
		return Arrays.asList(opt.split(","));
	}

	public void run() throws SaxonApiException {
		super.run();

		mFormatSpecs = new FormatSpecifications(tmpNs, sentenceTagOption,
		        wordTagOption, "http://www.w3.org/XML/1998/namespace", "lang",
		        inlineTagsOption, commaTagsOption, fullstopTagsOption,
		        spaceTagsOption, mergeableAttrOption);

		mXmlRebuilder.setFormatSpecifications(mFormatSpecs);

		long before = System.currentTimeMillis();

		while (mSource.moreDocuments()) {
			XdmNode doc = mSource.read();

			// find the inline sections on which tokenizeInlineSection()
			// will be called
			HashSet<XdmNode> inlineSections = new HashSet<XdmNode>();
			findInlineSections(doc, inlineSections);

			XdmNode tree = mXmlRebuilder.rebuild(doc, inlineSections);

			mResult.write(tree);
		}

		long after = System.currentTimeMillis();
		mLogger.debug("lexing time = " + (after - before) / 1000.0 + " s.");
	}
}
