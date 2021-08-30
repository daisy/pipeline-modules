package org.daisy.pipeline.tts;

import java.net.URI;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Deque;
import java.util.LinkedList;

import static javax.xml.stream.XMLStreamConstants.CDATA;
import static javax.xml.stream.XMLStreamConstants.CHARACTERS;
import static javax.xml.stream.XMLStreamConstants.COMMENT;
import static javax.xml.stream.XMLStreamConstants.END_DOCUMENT;
import static javax.xml.stream.XMLStreamConstants.END_ELEMENT;
import static javax.xml.stream.XMLStreamConstants.PROCESSING_INSTRUCTION;
import static javax.xml.stream.XMLStreamConstants.SPACE;
import static javax.xml.stream.XMLStreamConstants.START_DOCUMENT;
import static javax.xml.stream.XMLStreamConstants.START_ELEMENT;

import javax.xml.namespace.QName;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;

import com.xmlcalabash.util.TreeWriter;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.common.saxon.SaxonInputValue;

// Note that this class is currently not used
public class DefaultSSMLMarkSplitter implements SSMLMarkSplitter {

	private Processor mProc;

	public DefaultSSMLMarkSplitter(Processor proc) {
		mProc = proc;
	}

	@Override
	public Collection<Chunk> split(XdmNode ssml) {
		XMLStreamReader reader = new SaxonInputValue(ssml).asXMLStreamReader();
		Collection<Chunk> chunks = new ArrayList<Chunk>();
		String markName = null;
		URI docURI = URI.create("http://tmp");
		Deque<QName> parents = new LinkedList<>();
		TreeWriter tw = new TreeWriter(mProc);
		tw.startDocument(docURI);
		try {
			while (reader.hasNext()) {
				reader.next();
				switch (reader.getEventType()) {
				case START_ELEMENT:
					QName name = reader.getName();
					if (name.getLocalPart().equals(markNode.getLocalPart())) {
						// split
						for (QName p : parents)
							tw.addEndElement();
						tw.endDocument();
						chunks.add(new Chunk(tw.getResult(), markName));
						tw = null;
						for (int i = 0; i < reader.getAttributeCount(); i++)
							if (reader.getAttributeName(i).getLocalPart().equals(markNameAttr.getLocalPart()))
								markName = reader.getAttributeValue(i);
					} else {
						if (tw == null) {
							tw = new TreeWriter(mProc);
							tw.startDocument(docURI);
							for (QName p : parents)
								tw.addStartElement(new net.sf.saxon.s9api.QName(p));
						}
						tw.addStartElement(new net.sf.saxon.s9api.QName(name));
					}
					parents.offerLast(name);
					break;
				case END_ELEMENT:
					if (!parents.pollLast().getLocalPart().equals(markNode.getLocalPart()) && tw != null) {
						tw.addEndElement();
					}
					break;
				case SPACE:
				case CHARACTERS:
					if (!reader.getText().isEmpty()) {
						if (tw == null) {
							tw = new TreeWriter(mProc);
							tw.startDocument(docURI);
							for (QName p : parents)
								tw.addStartElement(new net.sf.saxon.s9api.QName(p));
						}
						tw.addText(reader.getText());
					}
					break;
				case START_DOCUMENT:
				case END_DOCUMENT:
				case PROCESSING_INSTRUCTION:
				case CDATA:
				case COMMENT:
				default:
				}
			}
		} catch (XMLStreamException e) {
		}
		for (QName p : parents) tw.addEndElement(); // just to be sure
		tw.endDocument();
		chunks.add(new Chunk(tw.getResult(), markName));
		return chunks;
	}

	private static final QName markNode = new QName("mark");
	private static final QName markNameAttr = new QName("name");
}
