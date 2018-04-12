package org.daisy.pipeline.braille.common;

import javax.xml.stream.XMLStreamReader;
import javax.xml.stream.XMLStreamWriter;
import javax.xml.transform.TransformerException;

import org.daisy.pipeline.braille.common.XMLStreamWriterHelper.BufferedXMLStreamWriter;

public interface XMLStreamToXMLStreamTransformer {
	
	public void transform(XMLStreamReader reader, BufferedXMLStreamWriter writer) throws TransformerException;
	
}
