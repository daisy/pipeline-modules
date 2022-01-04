package org.daisy.pipeline.fileset.calabash.impl;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;
import java.util.NoSuchElementException;

import javax.xml.namespace.QName;
import static javax.xml.stream.XMLStreamConstants.END_DOCUMENT;
import static javax.xml.stream.XMLStreamConstants.END_ELEMENT;
import static javax.xml.stream.XMLStreamConstants.START_DOCUMENT;
import static javax.xml.stream.XMLStreamConstants.START_ELEMENT;
import javax.xml.stream.XMLStreamException;
import javax.xml.XMLConstants;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;

import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.SaxonApiException;

import org.daisy.common.saxon.SaxonHelper;
import org.daisy.common.stax.BaseURIAwareXMLStreamReader;
import org.daisy.common.stax.BaseURIAwareXMLStreamWriter;
import org.daisy.common.stax.XMLStreamWriterHelper;
import org.daisy.common.transform.TransformerException;
import org.daisy.common.xproc.calabash.XProcStep;
import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.common.xproc.calabash.XMLCalabashInputValue;
import org.daisy.common.xproc.calabash.XMLCalabashOutputValue;
import org.daisy.pipeline.file.FileUtils;

import org.osgi.service.component.annotations.Component;

import org.slf4j.Logger;

public class AddEntryStep extends DefaultStep implements XProcStep {

	@Component(
		name = "pxi:fileset-add-entry",
		service = { XProcStepProvider.class },
		property = { "type:String={http://www.daisy.org/ns/pipeline/xproc/internal}fileset-add-entry" }
	)
	public static class StepProvider implements XProcStepProvider {
		@Override
		public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
			return new AddEntryStep(runtime, step);
		}
	}

	private static final QName _HREF = new QName("href");
	private static final QName _MEDIA_TYPE = new QName("media-type");
	private static final QName _ORIGINAL_HREF = new QName("original-href");
	private static final net.sf.saxon.s9api.QName _FIRST = new net.sf.saxon.s9api.QName("first");
	private static final net.sf.saxon.s9api.QName _REPLACE = new net.sf.saxon.s9api.QName("replace");
	private static final net.sf.saxon.s9api.QName _REPLACE_ATTRIBUTES = new net.sf.saxon.s9api.QName("replace-attributes");
	private static final QName XML_BASE = new QName(XMLConstants.XML_NS_URI, "base", "xml");
	private static final QName D_FILE = new QName("http://www.daisy.org/ns/pipeline/data", "file", "d");

	private ReadablePipe sourceFilesetPipe = null;
	private ReadablePipe sourceInMemoryPipe = null;
	private ReadablePipe entryPipe = null;
	private WritablePipe resultFilesetPipe = null;
	private WritablePipe resultInMemoryPipe = null;
	private Map<QName,String> fileAttributes = null;

	private AddEntryStep(XProcRuntime runtime, XAtomicStep step) {
		super(runtime, step);
	}

	@Override
	public void setInput(String port, ReadablePipe pipe) {
		if ("source.fileset".equals(port))
			sourceFilesetPipe = pipe;
		else if ("source.in-memory".equals(port))
			sourceInMemoryPipe = pipe;
		else if ("entry".equals(port))
			entryPipe = pipe;
	}

	@Override
	public void setOutput(String port, WritablePipe pipe) {
		if ("result.fileset".equals(port))
			resultFilesetPipe = pipe;
		else if ("result.in-memory".equals(port))
			resultInMemoryPipe = pipe;
	}

	@Override
	public void reset() {
		sourceFilesetPipe.resetReader();
		sourceInMemoryPipe.resetReader();
		entryPipe.resetReader();
		resultFilesetPipe.resetWriter();
		resultInMemoryPipe.resetWriter();
		if (fileAttributes != null) fileAttributes.clear();
	}

	public void setParameter(net.sf.saxon.s9api.QName name, RuntimeValue value) {
		if (fileAttributes == null)
			fileAttributes = new HashMap<>();
		fileAttributes.put(SaxonHelper.jaxpQName(name), value.getString());
	}

	public void setParameter(String port, net.sf.saxon.s9api.QName name, RuntimeValue value) {
		setParameter(name, value);
	}

	@Override
	public void run() throws SaxonApiException {
		super.run();
		try {
			XdmNode entry;
			URI href; {
				String option = getOption(new net.sf.saxon.s9api.QName(_HREF), "");
				if ("".equals(option)) {
					if (!entryPipe.moreDocuments())
						throw TransformerException.wrap(
							new IllegalArgumentException("Expected 1 document on the entry port"));
					entry = entryPipe.read();
					href = entry.getBaseURI();
				} else {
					if (entryPipe.moreDocuments())
						throw TransformerException.wrap(
							new IllegalArgumentException("Expected 0 documents on the entry port"));
					entry = null;
					href = URI.create(option);
				}
			}
			URI originalHref; {
				String option = getOption(new net.sf.saxon.s9api.QName(_ORIGINAL_HREF), "");
				if ("".equals(option))
					originalHref = null;
				else
					originalHref = URI.create(option);
			}
			String mediaType = getOption(new net.sf.saxon.s9api.QName(_MEDIA_TYPE), "");
			if ("".equals(mediaType)) mediaType = null;
			boolean first = getOption(_FIRST, false);
			boolean replace = getOption(_REPLACE, false);
			boolean replaceAttributes = getOption(_REPLACE_ATTRIBUTES, false);
			boolean added = addEntry(new XMLCalabashInputValue(sourceFilesetPipe).asXMLStreamReader(),
			                         new XMLCalabashOutputValue(resultFilesetPipe, runtime).asXMLStreamWriter(),
			                         href, originalHref, mediaType, fileAttributes, first, replace, replaceAttributes,
			                         logger);
			if (added && entry != null && first)
				resultInMemoryPipe.write(entry);
			while (sourceInMemoryPipe.moreDocuments())
				resultInMemoryPipe.write(sourceInMemoryPipe.read());
			if (added && entry != null && !first)
				resultInMemoryPipe.write(entry);
		} catch (Throwable e) {
			throw XProcStep.raiseError(e, step);
		}
	}

	private static boolean addEntry(BaseURIAwareXMLStreamReader source, BaseURIAwareXMLStreamWriter result,
	                                URI href, URI originalHref, String mediaType, Map<QName,String> otherAttributes,
	                                boolean first, boolean replace, boolean replaceAttributes, Logger logger)
			throws XMLStreamException {
		URI filesetBase = source.getBaseURI();
		result.setBaseURI(filesetBase);
		result.writeStartDocument();
		href = FileUtils.normalizeURI(href);
		int depth = 0;
		boolean exists = false;
		boolean hasXmlBase = false;
	  document: while (true)
			try {
				int event = source.next();
				switch (event) {
				case START_DOCUMENT:
					break;
				case END_DOCUMENT:
					break document;
				case START_ELEMENT:
					if (depth == 0) {
						// <d:fileset>
						for (int i = 0; i < source.getAttributeCount(); i++)
							if (XML_BASE.equals(source.getAttributeName(i))) {
								hasXmlBase = true;
								filesetBase = filesetBase.resolve(source.getAttributeValue(i));
								break;
							}
						if (!hasXmlBase && !href.isAbsolute())
							logger.warn("Adding a relative resource to a file set with no base directory");
						filesetBase = FileUtils.normalizeURI(filesetBase);
						if (originalHref != null)
							originalHref = FileUtils.normalizeURI(filesetBase.resolve(originalHref));
						XMLStreamWriterHelper.writeStartElement(result, source.getName());
						XMLStreamWriterHelper.writeAttributes(result, source);
						depth++;
						if (first) {
							// insert entry
							XMLStreamWriterHelper.writeStartElement(result, D_FILE);
							if (hasXmlBase)
								href = FileUtils.relativizeURI(filesetBase.resolve(href), filesetBase);
							XMLStreamWriterHelper.writeAttribute(result, _HREF, href.toASCIIString());
							writeFileAttributes(result, null, originalHref, mediaType, otherAttributes);
							result.writeEndElement();
						}
						break;
					} else if (depth == 1) {
						// <d:file>
						boolean match = false; {
							if (!exists)
								for (int i = 0; i < source.getAttributeCount(); i++)
									if (_HREF.equals(source.getAttributeName(i))) {
										match = href.equals(
											FileUtils.normalizeURI(filesetBase.resolve(source.getAttributeValue(i))));
										break;
									}
						}
						if (match) {
							exists = true;
							if (replace) {
								// skip entry
							  element: while (true) {
									event = source.next();
									switch (event) {
									case START_ELEMENT:
										depth++;
										break;
									case END_ELEMENT:
										if (depth == 1) break element;
										depth--;
										break;
									default:
									}
								}
								break;
							} else if (replaceAttributes) {
								// update entry
								XMLStreamWriterHelper.writeStartElement(result, source.getName());
								Map<QName,String> existingAttributes = new HashMap<>(); {
									for (int i = 0; i < source.getAttributeCount(); i++)
										existingAttributes.put(source.getAttributeName(i), source.getAttributeValue(i));
								}
								writeFileAttributes(result, existingAttributes, originalHref, mediaType, otherAttributes);
								depth++;
								break;
							}
						}
					}
					XMLStreamWriterHelper.writeElement(result, source);
					break;
				case END_ELEMENT:
					depth--;
					if (depth == 0) {
						// </d:fileset>
						if (!first && (replace || !exists)) {
							// insert entry
							XMLStreamWriterHelper.writeStartElement(result, D_FILE);
							if (hasXmlBase)
								href = FileUtils.relativizeURI(filesetBase.resolve(href), filesetBase);
							XMLStreamWriterHelper.writeAttribute(result, _HREF, href.toASCIIString());
							writeFileAttributes(result, null, originalHref, mediaType, otherAttributes);
							result.writeEndElement();
						}
					}
				default:
					XMLStreamWriterHelper.writeEvent(result, source);
				}
			} catch (NoSuchElementException e) {
				break;
			}
		result.writeEndDocument();
		// return whether a new entry was added
		return replace || !exists;
	}

	private static void writeFileAttributes(BaseURIAwareXMLStreamWriter result, Map<QName,String> existingAttributes,
	                                        URI originalHref, String mediaType, Map<QName,String> otherAttributes)
			throws XMLStreamException {
		if (originalHref != null)
			XMLStreamWriterHelper.writeAttribute(result, _ORIGINAL_HREF, originalHref.toASCIIString());
		if (mediaType != null)
			XMLStreamWriterHelper.writeAttribute(result, _MEDIA_TYPE, mediaType);
		if (otherAttributes != null)
			for (QName attr : otherAttributes.keySet())
				if (_HREF.equals(attr) ||
				    _ORIGINAL_HREF.equals(attr) ||
				    _MEDIA_TYPE.equals(attr))
					throw TransformerException.wrap(
						new IllegalArgumentException(
							"href, original-href and media-type are not allowed file attributes"));
				else
					XMLStreamWriterHelper.writeAttribute(result, attr, otherAttributes.get(attr));
		if (existingAttributes != null)
			for (QName attr : existingAttributes.keySet())
				if ((originalHref == null || !_ORIGINAL_HREF.equals(attr)) &&
				    (mediaType == null || !_MEDIA_TYPE.equals(attr)) &&
				    (otherAttributes == null || !otherAttributes.containsKey(attr)))
					XMLStreamWriterHelper.writeAttribute(result, attr, existingAttributes.get(attr));
	}
}
