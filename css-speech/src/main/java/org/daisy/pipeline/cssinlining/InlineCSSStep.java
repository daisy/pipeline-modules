package org.daisy.pipeline.cssinlining;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmNodeKind;
import net.sf.saxon.s9api.XdmSequenceIterator;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

public class InlineCSSStep extends DefaultStep implements TreeWriterFactory {

	private String mStyleNsOption;
	private String mEmbedContainerURIOpt;
	private List<String> mStylesheetURIOpt;
	private ReadablePipe mEmbedded;
	private ReadablePipe mSource = null;
	private WritablePipe mResult = null;
	private XProcRuntime mRuntime;

	public InlineCSSStep(XProcRuntime runtime, XAtomicStep step) {
		super(runtime, step);
		mRuntime = runtime;
	}

	public void setInput(String port, ReadablePipe pipe) {
		if ("embedded".equals(port))
			mEmbedded = pipe;
		else
			mSource = pipe;
	}

	@Override
	public void setOption(QName name, RuntimeValue value) {
		super.setOption(name, value);
		String optName = name.getLocalName();
		if ("style-ns".equalsIgnoreCase(optName)) {
			mStyleNsOption = value.getString();
		} else if ("embed-container-uri".equalsIgnoreCase(optName)) {
			mEmbedContainerURIOpt = value.getString();
		} else if ("stylesheet-uri".equalsIgnoreCase(optName)) {
			//caution: sometimes the option starts with ','.
			//The blank URI will be replaced in analyzer.analyze
			mStylesheetURIOpt = Arrays.asList(value.getString().split(","));
		} else {
			mRuntime.error(new Throwable("unknown option " + optName));
			return;
		}
	}

	public void setOutput(String port, WritablePipe pipe) {
		mResult = pipe;
	}

	public void reset() {
		mSource.resetReader();
		mResult.resetWriter();
	}

	private static String getText(XdmNode node) {
		StringBuilder sb = new StringBuilder();
		XdmSequenceIterator it = node.axisIterator(Axis.DESCENDANT);
		while (it.hasNext()) {
			XdmNode item = (XdmNode) it.next();
			if (item.getNodeKind() == XdmNodeKind.TEXT) {
				sb.append(item.getStringValue());
			}
		}
		return sb.toString();
	}

	public void run() throws SaxonApiException {
		super.run();

		List<String> embeddedCSS = new ArrayList<String>();
		if (mEmbedded != null) {
			while (mEmbedded.moreDocuments()) {
				XdmNode source = mEmbedded.read();
				embeddedCSS.add(getText(source));
			}
		}

		CSSInliner inliner = new CSSInliner();
		SpeechSheetAnalyser analyzer = new SpeechSheetAnalyser();
		try {
			analyzer.analyse(mStylesheetURIOpt, embeddedCSS, mEmbedContainerURIOpt);
		} catch (Throwable t) {
			mRuntime.info(null, null, t.toString());
			//copy the input
			while (mSource.moreDocuments()) {
				mResult.write(mSource.read());
			}
			return;
		}

		while (mSource.moreDocuments()) {
			XdmNode source = mSource.read();

			// rebuild the document with the additional style info
			XdmNode rebuilt = inliner.inline(this, source.getDocumentURI(), source, analyzer,
			        mStyleNsOption);

			mResult.write(rebuilt);
		}
	}

	@Override
	public TreeWriter newInstance() {
		return new TreeWriter(mRuntime);
	}
}
