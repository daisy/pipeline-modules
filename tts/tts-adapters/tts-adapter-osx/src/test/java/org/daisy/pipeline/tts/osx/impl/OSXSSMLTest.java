package org.daisy.pipeline.tts.osx.impl;

import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Map;
import java.util.TreeMap;

import com.xmlcalabash.util.TreeWriter;

import junit.framework.Assert;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.common.saxon.xslt.ThreadUnsafeXslTransformer;
import org.daisy.common.saxon.xslt.XslTransformCompiler;

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
		String voice = "john";

		TreeWriter tw = new TreeWriter(Proc);
		tw.startDocument(new URI("http://test"));
		tw.startContent();
		tw.addStartElement(new QName(SsmlNs, "x"));
		tw.addStartElement(new QName(SsmlNs, "y"));
		tw.addAttribute(new QName(null, "attr"), "attr-val");
		tw.addEndElement();
		tw.addText("this is text");
		tw.addEndElement();

		Map<String, Object> params = new TreeMap<String, Object>();
		params.put("voice", voice);

		String result = Transformer.transformToString(tw.getResult(), params);

		Assert.assertEquals("this is text[[slnc 250ms]]", result);

	}

	@Test
	public void noDocumentRoot() throws URISyntaxException, SaxonApiException {
		String voice = "john";

		TreeWriter tw = new TreeWriter(Proc);
		tw.startDocument(new URI("http://test"));
		tw.startContent();
		tw.addStartElement(new QName(SsmlNs, "x"));
		tw.addStartElement(new QName(SsmlNs, "y"));
		tw.addAttribute(new QName(null, "attr"), "attr-val");
		tw.addEndElement();
		tw.addText("this is text");
		tw.addEndElement();

		Map<String, Object> params = new TreeMap<String, Object>();
		params.put("voice", voice);

		XdmNode firstChild = (XdmNode) tw.getResult().axisIterator(Axis.CHILD).next();

		String result = Transformer.transformToString(firstChild, params);

		Assert.assertEquals("this is text[[slnc 250ms]]", result);

	}
}
