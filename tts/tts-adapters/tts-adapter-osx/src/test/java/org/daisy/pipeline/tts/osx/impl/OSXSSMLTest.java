package org.daisy.pipeline.tts.osx.impl;

import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Map;
import java.util.TreeMap;

import com.xmlcalabash.util.TreeWriter;
import com.xmlcalabash.util.TypeUtils;

import junit.framework.Assert;

import net.sf.saxon.om.AttributeMap;
import net.sf.saxon.om.EmptyAttributeMap;
import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.common.xslt.ThreadUnsafeXslTransformer;
import org.daisy.common.xslt.XslTransformCompiler;

import org.junit.Before;
import org.junit.Test;

public class OSXSSMLTest {

	private ThreadUnsafeXslTransformer Transformer;
	private static Processor Proc = new Processor(false);
	private static String SsmlNs = "http://www.w3.org/2001/10/synthesis";

	@Before
	public void setUp() throws SaxonApiException {
		InputStream is = this.getClass().getResourceAsStream("/transform-ssml.xsl");
		Transformer = new XslTransformCompiler(Proc.getUnderlyingConfiguration())
		        .compileStylesheet(is).newTransformer();
	}

	@Test
	public void simpleConversion() throws URISyntaxException, SaxonApiException {
		String endingmark = "emark";
		String voice = "john";

		TreeWriter tw = new TreeWriter(Proc);
		tw.startDocument(URI.create(""));
		tw.addStartElement(new QName(SsmlNs, "x"));
		AttributeMap attrs = EmptyAttributeMap.getInstance()
			.put(TypeUtils.attributeInfo(new QName(null, "attr"), "attr-val"));
		tw.addStartElement(new QName(SsmlNs, "y"), attrs);
		tw.addEndElement();
		tw.addText("this is text");
		tw.addEndElement();

		Map<String, Object> params = new TreeMap<String, Object>();
		params.put("ending-mark", endingmark);
		params.put("voice", voice);

		String result = Transformer.transformToString(tw.getResult(), params);

		Assert.assertEquals("this is text[[slnc 250ms]]", result);

	}

	@Test
	public void noDocumentRoot() throws URISyntaxException, SaxonApiException {
		String endingmark = "emark";
		String voice = "john";

		TreeWriter tw = new TreeWriter(Proc);
		tw.startDocument(URI.create(""));
		tw.startDocument(new URI("http://test"));
		tw.addStartElement(new QName(SsmlNs, "x"));
		AttributeMap attrs = EmptyAttributeMap.getInstance()
			.put(TypeUtils.attributeInfo(new QName(null, "attr"), "attr-val"));
		tw.addStartElement(new QName(SsmlNs, "y"), attrs);
		tw.addEndElement();
		tw.addText("this is text");
		tw.addEndElement();

		Map<String, Object> params = new TreeMap<String, Object>();
		params.put("ending-mark", endingmark);
		params.put("voice", voice);

		XdmNode firstChild = (XdmNode) tw.getResult().axisIterator(Axis.CHILD).next();

		String result = Transformer.transformToString(firstChild, params);

		Assert.assertEquals("this is text[[slnc 250ms]]", result);

	}
}
