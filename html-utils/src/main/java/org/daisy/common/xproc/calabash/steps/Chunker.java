package org.daisy.common.xproc.calabash.steps;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.function.Consumer;
import java.util.function.Predicate;
import java.util.function.Supplier;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.regex.Pattern;
import java.util.Stack;
import java.util.SortedSet;
import java.util.TreeSet;

import javax.xml.namespace.QName;
import static javax.xml.stream.XMLStreamConstants.CHARACTERS;
import static javax.xml.stream.XMLStreamConstants.END_DOCUMENT;
import static javax.xml.stream.XMLStreamConstants.END_ELEMENT;
import static javax.xml.stream.XMLStreamConstants.START_DOCUMENT;
import static javax.xml.stream.XMLStreamConstants.START_ELEMENT;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;

import com.google.common.collect.Iterators;

import com.xmlcalabash.model.RuntimeValue;

import net.sf.saxon.Configuration;
import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmItem;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmNodeKind;
import net.sf.saxon.sxpath.XPathExpression;
import net.sf.saxon.trans.XPathException;

import org.daisy.common.saxon.NodeToXMLStreamTransformer;
import org.daisy.common.saxon.SaxonHelper;
import org.daisy.common.stax.BaseURIAwareXMLStreamReader;
import org.daisy.common.stax.BaseURIAwareXMLStreamWriter;
import static org.daisy.common.stax.XMLStreamWriterHelper.getAttributes;
import static org.daisy.common.stax.XMLStreamWriterHelper.writeAttribute;
import static org.daisy.common.stax.XMLStreamWriterHelper.writeCharacters;
import static org.daisy.common.stax.XMLStreamWriterHelper.writeDocument;
import static org.daisy.common.stax.XMLStreamWriterHelper.writeEvent;
import static org.daisy.common.stax.XMLStreamWriterHelper.writeStartElement;
import org.daisy.common.transform.TransformerException;

// The transformation consists of two passes. In the first pass, the split points are computed based
// on the provided stylesheets. In the second pass, the document is split into chunks. Because the
// XMLStreamToXMLStreamTransformer interface does not yet support reading the input document more
// than once, we use the Saxon specific NodeToXMLStreamTransformer interface.
class Chunker implements NodeToXMLStreamTransformer {
	
	final Configuration config;
	final RuntimeValue isChunkOption;
	final QName linkAttributeName;
	
	private static final QName _ID = new QName("id");
	private static final QName XML_ID = new QName("http://www.w3.org/XML/1998/namespace", "id", "xml");
	
	Chunker(RuntimeValue isChunkOption, QName linkAttributeName, Configuration config) {
		this.config = config;
		this.isChunkOption = isChunkOption;
		this.linkAttributeName = linkAttributeName;
	}
	
	private Stack<QName> parents;
	private Stack<Map<QName,String>> parentAttrs;
	private Stack<Integer> currentPath;
	private Iterator<SplitPoint> splitPoints;
	private Map<String,Integer> idToChunk;
	private SplitPoint nextSplitPoint;
	
	public void transform(Iterator<XdmNode> input, Supplier<BaseURIAwareXMLStreamWriter> output) throws TransformerException {
		XdmNode doc = Iterators.getOnlyElement(input);
		BaseURIAwareXMLStreamReader reader;
		try {
			reader = SaxonHelper.nodeReader(doc, config);
			SortedSet<SplitPoint> collectSplitPoints = new TreeSet<>();
			Map<String,List<Integer>> collectIds = new HashMap<>();
			getSplitPoints(config, doc, isChunkOption, collectSplitPoints, collectIds);
			idToChunk = new HashMap<String,Integer>();
			int n = 1;
			for (SplitPoint sp : collectSplitPoints) {
				for (String id : collectIds.keySet()) {
					if (sp.compareTo(collectIds.get(id)) > 0) {
						idToChunk.put(id, n);
						collectIds.remove(id);
					}
				}
				n++;
			}
			for (String id : collectIds.keySet())
				idToChunk.put(id, n);
			splitPoints = collectSplitPoints.iterator();
		} catch (XPathException | SaxonApiException e) {
			throw new TransformerException(e);
		}
		if (splitPoints.hasNext()) {
			if (doc.getBaseURI() != null)
				output = setBaseURI(output, doc.getBaseURI());
			transform(reader, output);
		} else
			try {
				BaseURIAwareXMLStreamWriter writer = output.get();
				if (doc.getBaseURI() != null)
					writer.setBaseURI(doc.getBaseURI());
				writeDocument(writer, reader);
			} catch (XMLStreamException e) {
				throw new TransformerException(e);
			}
	}
	
	void transform(BaseURIAwareXMLStreamReader reader, Supplier<BaseURIAwareXMLStreamWriter> writers) throws TransformerException {
		nextSplitPoint = null;
		if (splitPoints.hasNext())
			nextSplitPoint = splitPoints.next();
		parents = new Stack<QName>();
		parentAttrs = new Stack<Map<QName,String>>();
		boolean containsSplitPoint = true;
		Stack<Boolean> containsSplitPointStack = new Stack<Boolean>();
		currentPath = new Stack<Integer>();
		int elementCount = 0;
		boolean isRoot = true;
		BaseURIAwareXMLStreamWriter writer = writers.get();
		try {
			URI sourceBaseURI = reader.getBaseURI();
			writer.writeStartDocument();
			while (true)
				try {
					int event = reader.next();
					switch (event) {
					case START_ELEMENT:
						elementCount++;
						containsSplitPointStack.push(containsSplitPoint);
						if (isRoot)
							isRoot = false;
						else {
							currentPath.add(elementCount * 2);
							if (containsSplitPoint && isSplitPoint(currentPath, SplitPoint.Side.BEFORE, nextSplitPoint))
								split(writer, writer = writers.get());
							containsSplitPoint = containsSplitPoint(currentPath, nextSplitPoint);
						}
						writeStartElement(writer, reader);
						for (int i = 0; i < reader.getAttributeCount(); i++) {
							QName attr = reader.getAttributeName(i);
							String val = reader.getAttributeValue(i);
							if (sourceBaseURI != null)
								if (attr.equals(linkAttributeName) && val.startsWith("#")) {
									String id = val.substring(1);
									if (idToChunk.containsKey(id)) {
										URI currentBaseURI = writer.getBaseURI();
										URI targetBaseURI = getChunkBaseURI(sourceBaseURI, idToChunk.get(id));
										if (!currentBaseURI.equals(targetBaseURI))
											val = relativize(currentBaseURI, targetBaseURI).toASCIIString() + val; }}
							writeAttribute(writer, attr, val);
						}
						elementCount = 0;
						if (containsSplitPoint) {
							parents.push(reader.getName());
							parentAttrs.push(getAttributes(reader));
						}
						break;
					case END_ELEMENT:
						if (containsSplitPoint) {
							parents.pop();
							parentAttrs.pop();
						}
						writer.writeEndElement();
						containsSplitPoint = containsSplitPointStack.pop();
						if (containsSplitPoint && isSplitPoint(currentPath, SplitPoint.Side.AFTER, nextSplitPoint))
							split(writer, writer = writers.get());
						if (!currentPath.isEmpty()) // root element
							elementCount = currentPath.pop() / 2;
						break;
					case CHARACTERS:
						currentPath.add(elementCount * 2 + 1);
						if (containsSplitPoint && isSplitPoint(currentPath, SplitPoint.Side.BEFORE, nextSplitPoint))
							split(writer, writer = writers.get());
						writeCharacters(writer, reader);
						if (containsSplitPoint && isSplitPoint(currentPath, SplitPoint.Side.AFTER, nextSplitPoint))
							split(writer, writer = writers.get());
						currentPath.pop();
						break;
					case START_DOCUMENT:
					case END_DOCUMENT:
						break;
					default:
						writeEvent(writer, event, reader);
					}
				} catch (NoSuchElementException e) {
					break;
				}
			writer.writeEndDocument();
		} catch (XMLStreamException e) {
			throw new TransformerException(e);
		}
	}
	
	void split(XMLStreamWriter writer, XMLStreamWriter newWriter) throws XMLStreamException {
		for (int i = parents.size(); i > 0; i--)
			writer.writeEndElement();
		writer.writeEndDocument();
		newWriter.writeStartDocument();
		for (int i = 0; i < parents.size(); i++) {
			writeStartElement(newWriter, parents.get(i));
			for (Map.Entry<QName,String> attr : parentAttrs.get(i).entrySet())
				if (!(attr.getKey().equals(_ID) || attr.getKey().equals(XML_ID)))
					writeAttribute(newWriter, attr);
		}
		nextSplitPoint = splitPoints.hasNext() ? splitPoints.next() : null;
	}
	
	static Supplier<BaseURIAwareXMLStreamWriter> setBaseURI(Supplier<BaseURIAwareXMLStreamWriter> output, URI sourceBaseURI) {
		return new Supplier<BaseURIAwareXMLStreamWriter>() {
			int supplied = 0;
			public BaseURIAwareXMLStreamWriter get() throws TransformerException {
				BaseURIAwareXMLStreamWriter writer = output.get();
				try {
					writer.setBaseURI(getChunkBaseURI(sourceBaseURI, ++supplied));
				} catch (XMLStreamException e) {
					throw new TransformerException(e);
				}
				return writer;
			}
		};
	}
	
	static URI getChunkBaseURI(URI sourceBaseURI, int chunkNr) {
		return URI.create(sourceBaseURI.toASCIIString().replaceAll("^(.+?)(\\.[^\\.]+)$", "$1-" + chunkNr + "$2"));
	}
	
	final static boolean isSplitPoint(List<Integer> elementPath, SplitPoint.Side side, SplitPoint splitPoint) {
		return splitPoint != null && splitPoint.equals(elementPath, side);
	}
	
	final static boolean containsSplitPoint(List<Integer> elementPath, SplitPoint splitPoint) {
		if (splitPoint == null)
			return false;
		if (elementPath.size() >= splitPoint.path.size())
			return false;
		return splitPoint.path.subList(0, elementPath.size()).equals(elementPath);
	}
	
	static void getSplitPoints(Configuration configuration, XdmNode source, RuntimeValue isChunkOption,
	                           SortedSet<SplitPoint> collectSplitPoints, Map<String,List<Integer>> collectIds)
			throws XPathException, SaxonApiException {
		net.sf.saxon.s9api.QName _ID = new net.sf.saxon.s9api.QName(Chunker._ID);
		net.sf.saxon.s9api.QName XML_ID = new net.sf.saxon.s9api.QName(Chunker.XML_ID);
		XPathExpression chunkMatcher = SaxonHelper.compileExpression(isChunkOption.getString(),
		                                                             isChunkOption.getNamespaceBindings(),
		                                                             configuration);
		Predicate<XdmNode> isChunk = node -> node.getNodeKind() == XdmNodeKind.ELEMENT && SaxonHelper.evaluateBoolean(chunkMatcher, node);
		new Consumer<XdmNode>() {
			Stack<Integer> currentPath = new Stack<>();
			int elementCount = 0;
			boolean isRoot = true;
			boolean idsOnly = false;
			public void accept(XdmNode node) {
				if (node.getNodeKind() == XdmNodeKind.DOCUMENT) {
					for (XdmItem i : SaxonHelper.axisIterable(node, Axis.CHILD))
						accept((XdmNode)i);
				} else if (node.getNodeKind() == XdmNodeKind.ELEMENT) {
					elementCount++;
					String id = node.getAttributeValue(XML_ID);
					if (id == null) id = node.getAttributeValue(_ID);
					if (isRoot) {
						if (id != null)
							collectIds.put(id, new ArrayList<>(currentPath));
						isRoot = false;
						elementCount = 0;
						for (XdmItem i : SaxonHelper.axisIterable(node, Axis.CHILD))
							accept((XdmNode)i);
					} else {
						currentPath.add(elementCount * 2);
						if (id != null)
							collectIds.put(id, new ArrayList<>(currentPath));
						boolean _idsOnly = idsOnly;
						if (!idsOnly && isChunk.test(node)) {
							getSplitPoints(node, currentPath, collectSplitPoints);
							idsOnly = true;
						}
						elementCount = 0;
						for (XdmItem i : SaxonHelper.axisIterable(node, Axis.CHILD))
							accept((XdmNode)i);
						elementCount = currentPath.pop() / 2;
						idsOnly = _idsOnly;
					}
				}
			}
		}.accept(source);
	}
	
	static void getSplitPoints(XdmNode element, List<Integer> path, SortedSet<SplitPoint> collect) {
		path = new ArrayList<>(path);
		while (!path.isEmpty()) {
			if (path.get(path.size() - 1) > 2
			    || !shouldPropagateBreak(element, SplitPoint.Side.BEFORE))
				collect.add(new SplitPoint(path, SplitPoint.Side.BEFORE).normalize());
			if (!shouldPropagateBreak(element, SplitPoint.Side.AFTER)) {
				if (skipWhiteSpaceNodes(element, SplitPoint.Side.AFTER)) {
					List<Integer> p = new ArrayList<>(path);
					p.set(p.size() - 1, p.get(p.size() - 1) + 2);
					collect.add(new SplitPoint(p, SplitPoint.Side.BEFORE).normalize());
				} else
					collect.add(new SplitPoint(path, SplitPoint.Side.AFTER).normalize());
			}
			element = (XdmNode)element.getParent();
			path = path.subList(0, path.size() - 1);
		}
	}
	
	static boolean shouldPropagateBreak(XdmNode element, SplitPoint.Side side) {
		for (XdmItem i : SaxonHelper.axisIterable(element, side == SplitPoint.Side.BEFORE ? Axis.PRECEDING_SIBLING
		                                                                                  : Axis.FOLLOWING_SIBLING)) {
			XdmNode n = (XdmNode)i;
			if (n.getNodeKind() == XdmNodeKind.ELEMENT)
				return false;
			else if (n.getNodeKind() == XdmNodeKind.TEXT && !isWhiteSpaceNode(n))
				return false;
		}
		return true;
	}
	
	static boolean skipWhiteSpaceNodes(XdmNode element, SplitPoint.Side side) {
		for (XdmItem i : SaxonHelper.axisIterable(element, side == SplitPoint.Side.BEFORE ? Axis.PRECEDING_SIBLING
		                                                                                  : Axis.FOLLOWING_SIBLING)) {
			XdmNode n = (XdmNode)i;
			if (n.getNodeKind() == XdmNodeKind.ELEMENT)
				return true;
			else if (n.getNodeKind() == XdmNodeKind.TEXT && !isWhiteSpaceNode(n))
				return false;
		}
		return false;
	}
	
	static final Pattern WHITESPACE_RE = Pattern.compile("\\s*");
	
	static boolean isWhiteSpaceNode(XdmNode textNode) {
		return isWhiteSpace(textNode.getStringValue());
	}
	
	static boolean isWhiteSpace(String text) {
		return WHITESPACE_RE.matcher(text).matches();
	}
	
	// FIXME: move to some common utility package
	static URI relativize(URI base, URI child) {
		try {
			if (base.isOpaque() || child.isOpaque()
			    || !Optional.ofNullable(base.getScheme()).orElse("").equalsIgnoreCase(Optional.ofNullable(child.getScheme()).orElse(""))
			    || !Optional.ofNullable(base.getAuthority()).equals(Optional.ofNullable(child.getAuthority())))
				return child;
			else {
				String bp = base.normalize().getPath();
				String cp = child.normalize().getPath();
				String relativizedPath;
				if (cp.startsWith("/")) {
					String[] bpSegments = bp.split("/", -1);
					String[] cpSegments = cp.split("/", -1);
					int i = bpSegments.length - 1;
					int j = 0;
					while (i > 0) {
						if (bpSegments[j].equals(cpSegments[j])) {
							i--;
							j++; }
						else
							break; }
					relativizedPath = "";
					while (i > 0) {
						relativizedPath += "../";
						i--; }
					while (j < cpSegments.length) {
						relativizedPath += cpSegments[j] + "/";
						j++; }
					relativizedPath = relativizedPath.substring(0, relativizedPath.length() - 1); }
				else
					relativizedPath = cp;
				if (relativizedPath.isEmpty())
					relativizedPath = "./";
				return new URI(null, null, relativizedPath, child.getQuery(), child.getFragment()); }
		} catch (URISyntaxException e) {
			throw new RuntimeException(e);
		}
	}
	
	/*
	 * The path of a node in the tree is encoded as a list of integers where each integer
	 * is an index of a child node, starting with the ancestor of the node that is a child
	 * of the root element and ending with the node itself. Indexes are even for elements
	 * (2, 4, ...) and uneven for text nodes (1, 3, ...). This definition matches the
	 * definition of EPUB canonical fragment identifiers (see
	 * http://www.idpf.org/epub/linking/cfi/#sec-epubcfi-def). [x, y, z] corresponds with
	 * /x/y/z in EPUB CFI.
	 */
	static class SplitPoint implements Comparable<SplitPoint> {
		
		enum Side { BEFORE, AFTER }
		final List<Integer> path;
		final Side side;
		
		SplitPoint(List<Integer> path, Side side) {
			if (path == null || side == null)
				throw new NullPointerException();
			if (path.isEmpty())
				throw new IllegalArgumentException();
			this.path = path;
			this.side = side;
		}
		
		// normalize to BEFORE
		SplitPoint normalize() {
			if (side == Side.BEFORE)
				return this;
			else {
				List<Integer> path = new ArrayList<>(this.path);
				path.set(path.size() - 1, path.get(path.size() - 1) + 1);
				return new SplitPoint(path, Side.BEFORE);
			}
		}
		
		@Override
		public int compareTo(SplitPoint o) {
			int minsize = Math.min(path.size(), o.path.size());
			for (int i = 0; i < minsize; i++) {
				int c = path.get(i).compareTo(o.path.get(i));
				if (c != 0)
					return c;
			}
			if (path.size() > minsize)
				return o.side == Side.BEFORE ? 1 : -1;
			else if (o.path.size() > minsize)
				return side == Side.BEFORE ? -1 : 1;
			else
				return side.compareTo(o.side);
		}
		
		/**
		 * @param path The position of the node
		 * @return -1 when the split point comes before the node, 0 when the split point lies inside
		 *         the node, 1 when the split point comes after the node.
		 */
		public int compareTo(List<Integer> path) {
			int minsize = Math.min(this.path.size(), path.size());
			for (int i = 0; i < minsize; i++) {
				int c = this.path.get(i).compareTo(path.get(i));
				if (c != 0)
					return c;
			}
			if (this.path.size() > minsize)
				return 0;
			else if (this.side == Side.BEFORE)
				return -1;
			else
				return 1;
		}
		
		@Override
		public int hashCode() {
			final int prime = 31;
			int result = 1;
			result = prime * result + ((path == null) ? 0 : path.hashCode());
			result = prime * result + ((side == null) ? 0 : side.hashCode());
			return result;
		}
		
		@Override
		public boolean equals(Object obj) {
			if (this == obj)
				return true;
			if (obj == null)
				return false;
			if (getClass() != obj.getClass())
				return false;
			SplitPoint other = (SplitPoint)obj;
			return equals(other.path, other.side);
		}
		
		public boolean equals(List<Integer> path, Side side) {
			if (path == null)
				return false;
			if (this.side != side)
				return false;
			if (!this.path.equals(path))
				return false;
			return true;
		}
		
		@Override
		public String toString() {
			StringBuilder b = new StringBuilder();
			b.append(side).append(' ');
			for (Integer i : path)
				b.append('/').append(i);
			return b.toString();
		}
	}
}
