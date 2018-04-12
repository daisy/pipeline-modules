package org.daisy.pipeline.braille.common;

import javax.xml.stream.XMLStreamWriter;
import javax.xml.transform.TransformerException;

import org.w3c.dom.Document;

public interface DOMToXMLStreamTransformer {
	
	public void transform(Document document, XMLStreamWriter writer) throws TransformerException;
	
}
