package org.daisy.pipeline.cssinlining;

import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;

import net.sf.saxon.dom.DocumentOverNodeInfo;
import net.sf.saxon.dom.NodeOverNodeInfo;
import net.sf.saxon.om.NameOfNode;
import net.sf.saxon.om.NamespaceBinding;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.tree.util.NamespaceIterator;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;

import com.google.common.collect.Iterables;
import com.google.common.collect.Iterators;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;

import cz.vutbr.web.css.CSSFactory;
import cz.vutbr.web.css.NodeData;
import cz.vutbr.web.css.StyleSheet;
import cz.vutbr.web.css.SupportedCSS;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.domassign.Analyzer;
import cz.vutbr.web.domassign.StyleMap;
import cz.vutbr.web.domassign.SupportedCSS21;

public class InlineCSSStep extends DefaultStep {

	private final static String mStyleNsPrefix = "tmp";
	private String mStyleNsOption;
	private String mMediumOption;
	private boolean mInheritOption;
	private List<String> mStylesheetURIOption;

	private ReadablePipe mSource = null;
	private WritablePipe mResult = null;
	private XProcRuntime mRuntime;

	public InlineCSSStep(XProcRuntime runtime, XAtomicStep step) {
		super(runtime, step);
		mRuntime = runtime;
	}

	public void setInput(String port, ReadablePipe pipe) {
		mSource = pipe;
	}

	@Override
	public void setOption(QName name, RuntimeValue value) {
		super.setOption(name, value);
		if ("medium".equalsIgnoreCase(name.getLocalName())) {
			mMediumOption = value.getString();
		} else if ("inherit".equalsIgnoreCase(name.getLocalName())) {
			mInheritOption = value.getBoolean();
		} else if ("style-ns".equalsIgnoreCase(name.getLocalName())) {
			mStyleNsOption = value.getString();
		} else if ("stylesheet-uri".equalsIgnoreCase(name.getLocalName())) {
			mStylesheetURIOption = Arrays.asList(value.getString().split(","));
		} else {
			mRuntime.getMessageListener().error(
			        new Throwable("unknown option " + name.getLocalName()));
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

	private boolean mFirst = true;

	public void run() throws SaxonApiException {
		super.run();

		SupportedCSS supportedCSS = SupportedCSS21.getInstance();
		CSSFactory.registerSupportedCSS(supportedCSS);
		if (!supportedCSS.isSupportedMedia(mMediumOption)) {
			mRuntime.getMessageListener().error(
			        new Throwable("medium '" + mMediumOption
			                + "' is not supported"));
			return;
		}

		// create a CSS matcher for the given stylesheets
		List<StyleSheet> styleSheets = new ArrayList<StyleSheet>();
		try {
			for (String uri : mStylesheetURIOption) {
				styleSheets.add(CSSFactory.parse(new URL(uri), "utf-8"));
			}
		} catch (Exception e) {
			StringBuilder b = new StringBuilder();
			for (String uri : mStylesheetURIOption) {
				b.append(", ");
				b.append(uri);
			}
			mRuntime.getMessageListener().error(
			        new Throwable("cannot load the CSS stylesheet(s)"
			                + b.toString()));
			return;
		}

		Analyzer analyser = new Analyzer(styleSheets);

		while (mSource.moreDocuments()) {
			XdmNode source = mSource.read();

			mFirst = true;

			DocumentOverNodeInfo doc = (DocumentOverNodeInfo) DocumentOverNodeInfo
			        .wrap(source.getUnderlyingNode());

			Document wrapped = (Document) WrapperOverWrapper.wrap(doc);

			// match the document with the stylesheet
			StyleMap styleMap = analyser.evaluateDOM(wrapped, mMediumOption,
			        mInheritOption);
			// rebuild the document with the additional style info
			TreeWriter tw = new TreeWriter(mRuntime);
			tw.startDocument(source.getDocumentURI());
			rebuild(tw, wrapped.getDocumentElement(), styleMap);
			tw.endDocument();

			mResult.write(tw.getResult());
		}
	}

	private void rebuild(TreeWriter tw, Node node, StyleMap styleMap) {
		if (node.getNodeType() == Node.COMMENT_NODE) {
			tw.addComment(node.getNodeValue());
		} else if (node.getNodeType() == Node.TEXT_NODE) {
			tw.addText(node.getNodeValue());
		} else if (node.getNodeType() == Node.PROCESSING_INSTRUCTION_NODE) {
			tw.addPI(node.getLocalName(), node.getNodeValue());
		} else if (node.getNodeType() == Node.ELEMENT_NODE) {

			NamespaceBinding[] bindings = null;
			if (mFirst) {
				List<NamespaceBinding> namespaces = new ArrayList<NamespaceBinding>();
				Iterators.<NamespaceBinding> addAll(namespaces,
				        NamespaceIterator
				                .iterateNamespaces(((NodeOverNodeInfo) node)
				                        .getUnderlyingNodeInfo()));
				bindings = Iterables.<NamespaceBinding> toArray(namespaces,
				        NamespaceBinding.class);
				mFirst = false;
			} else {
				bindings = ((NodeOverNodeInfo) node).getUnderlyingNodeInfo()
				        .getDeclaredNamespaces(null);
			}

			NodeInfo inode = ((NodeOverNodeInfo) node).getUnderlyingNodeInfo();
			tw.addStartElement(new NameOfNode(inode), inode.getSchemaType(),
			        bindings);

			NamedNodeMap attributes = node.getAttributes();
			for (int i = 0; i < attributes.getLength(); i++) {
				Node attr = attributes.item(i);
				if (attr.getPrefix() != null && attr.getPrefix().length() > 0)
					tw.addAttribute(
					        new QName(attr.getPrefix(), attr.getNamespaceURI(),
					                attr.getLocalName()), attr.getNodeValue());
				else
					tw.addAttribute(
					        new QName(attr.getNamespaceURI(), attr
					                .getLocalName()), attr.getNodeValue());
			}

			// ===== start inlining ===== //
			NodeData nd = styleMap.get((Element) node);
			if (nd != null) {
				for (String property : nd.getPropertyNames()) {
					Object val = null;
					Term<?> t = nd.getValue(property, false);
					if (t == null || t.getValue() == null)
						val = nd.getProperty(property, false);
					else
						val = t.getValue();
					if (val != null) {
						String str = null;
						if (val instanceof List<?>) {
							List<?> li = (List<?>) val;
							StringBuilder sb = new StringBuilder();
							Iterator it = li.iterator();
							sb.append(it.next());
							while (it.hasNext()) {
								Term<?> term = (Term<?>) it.next();
								sb.append("," + term.getValue().toString());
							}
							str = sb.toString();
						} else
							str = val.toString();
						tw.addAttribute(new QName(mStyleNsPrefix,
						        mStyleNsOption, property), str);
					}
				}
			}
			// ===== end inlining ===== //

			for (Node child = node.getFirstChild(); child != null; child = child
			        .getNextSibling())
				rebuild(tw, child, styleMap);

			tw.addEndElement();
		}
	}
}
