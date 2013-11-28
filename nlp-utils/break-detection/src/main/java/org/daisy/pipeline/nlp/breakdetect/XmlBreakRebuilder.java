package org.daisy.pipeline.nlp.breakdetect;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmNodeKind;
import net.sf.saxon.s9api.XdmSequenceIterator;

import org.daisy.pipeline.nlp.LanguageUtils.Language;
import org.daisy.pipeline.nlp.lexing.LexService;
import org.daisy.pipeline.nlp.lexing.LexService.LexerInitException;
import org.daisy.pipeline.nlp.lexing.LexService.Sentence;
import org.daisy.pipeline.nlp.lexing.LexService.TextReference;

import com.xmlcalabash.util.TreeWriter;

/**
 * This class is used to rebuild the input document with the additional XML
 * elements resulting from the lexing, i.e. the sentences and the words.
 * 
 * The algorithm is run multiple times until no unique IDs have been duplicated
 * (this is the main reason for its slow execution).
 * 
 * The algorithm processes the inline sections on-the-fly as soon as they are
 * detected by the InlineSectionFinder. Since the sections can be dispatched
 * over distinct branches of the document tree, the tree is rebuilt by
 * agglomerating tree paths with writeTree(), instead of the usual top-down way
 * whose the scope is too small.
 * 
 * The levels are used to quickly align the tree paths each other so that it is
 * easy to find the common ancestor of a group of leaves.
 */
public class XmlBreakRebuilder implements InlineSectionProcessor {

	private TreeWriter mTreeWriter;
	private LexService mLexer;
	private FormatSpecifications mSpecs;
	private XdmNode mPreviousNode; //last node written
	private int mPreviousLevel;
	private boolean mEnableSentenceCreate;
	private boolean mEnableWordCreate;
	private final static QName IDattr = new QName("id");

	public XdmNode rebuild(TreeWriterFactory treeWriterFactory,
	        LexService lexer, XdmNode doc, FormatSpecifications specs)
	        throws LexerInitException {
		mLexer = lexer;
		mSpecs = specs;

		mPreviousNode = getRoot(doc);
		mPreviousLevel = 0;
		mEnableSentenceCreate = false;
		mEnableWordCreate = false;

		Map<String, Integer> docIDs = new HashMap<String, Integer>();
		Map<String, Integer> resultIDs;
		Set<String> unsplittable = new HashSet<String>();
		getIDs(doc, docIDs);

		XdmNode result;
		do {

			mTreeWriter = treeWriterFactory.newInstance();
			mTreeWriter.startDocument(doc.getDocumentURI());
			XdmSequenceIterator iter = doc.axisIterator(Axis.CHILD);
			while (iter.hasNext()) {
				XdmNode n = (XdmNode) iter.next();
				if (n.getNodeKind() == XdmNodeKind.ELEMENT) {

					XdmNode root = n;
					mPreviousNode = root;
					mTreeWriter.addStartElement(root);
					mTreeWriter.addAttributes(root);
					mTreeWriter.addNamespace(mSpecs.tmpNsPrefix, mSpecs.tmpNs);

					new InlineSectionFinder().find(root, mPreviousLevel, specs,
					        this, unsplittable);

					break;
					//Some elements remain opened but they will be closed automatically by the 
					//serializer. There should be no node (PI, comments) after the root though.

				} else {
					mTreeWriter.addSubtree(n);
				}
			}
			mTreeWriter.endDocument();
			result = mTreeWriter.getResult();
			resultIDs = new HashMap<String, Integer>();
			getIDs(result, resultIDs);

		} while (getDuplicatedIDs(docIDs, resultIDs, unsplittable) != 0);

		mPreviousNode = null;
		mSpecs = null;
		mTreeWriter = null;
		mLexer = null;
		return result;
	}

	public static int getDuplicatedIDs(Map<String, Integer> ref,
	        Map<String, Integer> actual, Set<String> unsplittable) {
		int res = 0;
		for (Map.Entry<String, Integer> e : ref.entrySet()) {
			if (e.getValue() == 1
			        && !(Integer.valueOf(1).equals(actual.get(e.getKey())))) {
				unsplittable.add(e.getKey());
				++res;
			}
		}

		return res;
	}

	private static void getIDs(XdmNode node, Map<String, Integer> ids) {
		if (node.getNodeKind() != XdmNodeKind.ELEMENT
		        && node.getNodeKind() != XdmNodeKind.DOCUMENT) {
			return;
		}

		String id = node.getAttributeValue(IDattr);
		if (id != null) {
			Integer existing = ids.get(id);
			if (existing == null) {
				existing = 0;
			}
			ids.put(id, existing + 1);
		}

		XdmSequenceIterator iter = node.axisIterator(Axis.CHILD);
		while (iter.hasNext()) {
			getIDs((XdmNode) iter.next(), ids);
		}
	}

	private void addOneWord(TextReference word, List<Leaf> leaves,
	        List<String> text, XdmNode sentenceParent) {
		XdmNode wordParent = deepestAncestorOf(leaves, word.firstSegment,
		        word.lastSegment);
		if (wordParent == null)
			return;

		mEnableWordCreate = true;
		if (word.firstSegment == word.lastSegment) {

			writeTree(
			        leaves.get(word.firstSegment),
			        text.get(word.firstSegment).substring(word.firstIndex,
			                word.lastIndex), sentenceParent, wordParent);
		} else {
			writeTree(leaves.get(word.firstSegment), text
			        .get(word.firstSegment).substring(word.firstIndex),
			        sentenceParent, wordParent);
			for (int i = word.firstSegment + 1; i < word.lastSegment; ++i)
				writeTree(leaves.get(i), text.get(i), sentenceParent,
				        wordParent);
			writeTree(leaves.get(word.lastSegment), text.get(word.lastSegment)
			        .substring(0, word.lastIndex), sentenceParent, wordParent);
		}
		mEnableWordCreate = false;
		closeAllElementsUntil(wordParent, 1);
	}

	@Override
	public void onInlineSectionFound(List<Leaf> leaves, List<String> text,
	        Language lang) throws LexerInitException {

		mLexer.useLanguage(lang);
		List<Sentence> sentences = mLexer.split(text);

		int sSegBoundary = -1;
		int sIndexBoundary = -1;
		for (Sentence s : sentences) {
			//Gap between the previous sentence and the current sentence
			fillGap(sSegBoundary, sIndexBoundary, s.boundaries.firstSegment,
			        s.boundaries.firstIndex, leaves, text, null);

			sSegBoundary = s.boundaries.lastSegment;
			sIndexBoundary = s.boundaries.lastIndex;
			XdmNode sentenceParent = deepestAncestorOf(leaves,
			        s.boundaries.firstSegment, s.boundaries.lastSegment);
			if (sentenceParent == null) {
				//it can happen if the section is composed only of punctuation
				//marks inserted to help the Lexer
				continue;
			}
			mEnableSentenceCreate = true;
			int wSegBoundary = s.boundaries.firstSegment;
			int wIndexBoundary = s.boundaries.firstIndex;
			if (s.content != null)
				for (TextReference w : s.content) {
					//Gap between the previous word and the current word
					fillGap(wSegBoundary, wIndexBoundary, w.firstSegment,
					        w.firstIndex, leaves, text, sentenceParent);
					wSegBoundary = w.lastSegment;
					wIndexBoundary = w.lastIndex;
					addOneWord(w, leaves, text, sentenceParent);
				}
			//Gap between the last words and the end of the sentence
			fillGap(wSegBoundary, wIndexBoundary, s.boundaries.lastSegment,
			        s.boundaries.lastIndex, leaves, text, sentenceParent);

			mEnableSentenceCreate = false;
			closeAllElementsUntil(sentenceParent, 1);

		}
		//Gap between the last sentence and the end of the section
		fillGap(sSegBoundary, sIndexBoundary, -1, -1, leaves, text, null);
	}

	@Override
	public void onEmptySectionFound(List<Leaf> leaves) {
		for (int i = 0; i < leaves.size(); ++i) {
			writeTree(leaves.get(i), null, null, null);
		}
	}

	private void addNode(XdmNode node, int level) {

		switch (node.getNodeKind()) {
		case ELEMENT:
			mTreeWriter.addStartElement(node);
			mTreeWriter.addAttributes(node);
			mPreviousLevel = level;
			mPreviousNode = node;
			break;
		case COMMENT:
			mTreeWriter.addComment(node.getStringValue());
			mPreviousLevel = level - 1;
			mPreviousNode = node.getParent();
			break;
		case PROCESSING_INSTRUCTION:
			mTreeWriter.addPI(node.getNodeName().getClarkName(),
			        node.getStringValue());
			mPreviousLevel = level - 1;
			mPreviousNode = node.getParent();
			break;
		default:
			mTreeWriter.addSubtree(node);
			mPreviousLevel = level - 1;
			mPreviousNode = node.getParent();
			break;
		}
	}

	private void writeTree(Leaf leaf, String text, XdmNode sentenceParent,
	        XdmNode wordParent) {

		if (text != null && text.isEmpty())
			return; //the fillGap can call writeTree with empty strings

		if (leaf.formatting == null)
			return; //this happens when punctuation marks has been added to help the Lexer

		XdmNode[] leafPath = new XdmNode[leaf.level + 1];

		//*** Find the deepest common ancestor. ***
		//Also, keep track of the path between the ancestor and the leaf.
		XdmNode leafAncestor = leaf.formatting;
		XdmNode lastNodeAncestor = mPreviousNode;
		int minLevel = Math.min(leaf.level, mPreviousLevel);
		int topLevel = leaf.level;
		for (; topLevel > minLevel; --topLevel) {
			leafPath[topLevel] = leafAncestor;
			leafAncestor = leafAncestor.getParent();
		}
		for (int lastLevel = mPreviousLevel; lastLevel > minLevel; --lastLevel)
			lastNodeAncestor = lastNodeAncestor.getParent();

		for (; !same(leafAncestor, lastNodeAncestor); --topLevel) {
			leafPath[topLevel] = leafAncestor;
			leafAncestor = leafAncestor.getParent();
			lastNodeAncestor = lastNodeAncestor.getParent();
		}

		//*** Close the elements between the last written elements and the found common ancestor ***
		// Sentences and words have already been closed by closeAllElementsUntil()
		while (!same(mPreviousNode, lastNodeAncestor)) {
			mTreeWriter.addEndElement();
			mPreviousNode = mPreviousNode.getParent();
		}

		//*** Deal with sentences and words when they are direct ancestor's children
		if (mEnableSentenceCreate && same(lastNodeAncestor, sentenceParent)) {
			mTreeWriter.addStartElement(mSpecs.sentenceTag);
			mEnableSentenceCreate = false;
		}
		if (mEnableWordCreate && same(lastNodeAncestor, wordParent)) {
			mTreeWriter.addStartElement(mSpecs.wordTag);
			mEnableWordCreate = false;
		}

		//*** Open the new elements between the common ancestor (already opened) and the leaf (included) ***
		for (int l = topLevel + 1; l <= leaf.level; ++l) {
			XdmNode n = leafPath[l];
			addNode(n, l);
			if (mEnableSentenceCreate && same(n, sentenceParent)) {
				mEnableSentenceCreate = false;
				mTreeWriter.addStartElement(mSpecs.sentenceTag);
			}
			if (mEnableWordCreate && same(n, wordParent)) {
				mEnableWordCreate = false;
				mTreeWriter.addStartElement(mSpecs.wordTag);
			}
		}

		if (text != null) {
			mTreeWriter.addText(text);
			mPreviousLevel = leaf.level;
		}

	}

	/**
	 * @param dest is not closed.
	 * @param extra is used to close additional nodes like sentences or words
	 */
	private void closeAllElementsUntil(XdmNode dest, int extra) {
		while (!same(mPreviousNode, dest)) {
			mTreeWriter.addEndElement();
			mPreviousNode = mPreviousNode.getParent();
			--mPreviousLevel;
		}
		for (; extra > 0; --extra) {
			mTreeWriter.addEndElement();
		}
	}

	private void fillGap(int leftSegment, int leftIndex, int rightSegment,
	        int rightIndex, List<Leaf> leaves, List<String> text,
	        XdmNode sentenceParent) {

		if (leftSegment == -1) {
			for (leftSegment = 0; leftSegment < text.size()
			        && text.get(leftSegment) == null; ++leftSegment) {
				writeTree(leaves.get(leftSegment), null, sentenceParent, null);
			}
			leftIndex = 0;
		}

		int formerRightSegment = rightSegment;
		if (rightSegment == -1) {
			rightSegment = text.size() - 1;
			formerRightSegment = rightSegment;
			for (; rightSegment >= 0 && text.get(rightSegment) == null; --rightSegment);
			if (rightSegment >= 0) {
				rightIndex = text.get(rightSegment).length();
			}
		}

		if (leftSegment < rightSegment) {
			writeTree(leaves.get(leftSegment),
			        text.get(leftSegment).substring(leftIndex), sentenceParent,
			        null);

			for (int k = leftSegment + 1; k < rightSegment; ++k)
				writeTree(leaves.get(k), text.get(k), sentenceParent, null);

			writeTree(leaves.get(rightSegment), text.get(rightSegment)
			        .substring(0, rightIndex), sentenceParent, null);
		} else if (leftSegment == rightSegment && rightIndex > leftIndex) {
			writeTree(leaves.get(leftSegment),
			        text.get(leftSegment).substring(leftIndex, rightIndex),
			        sentenceParent, null);
		}

		for (++rightSegment; rightSegment <= formerRightSegment; ++rightSegment) {
			writeTree(leaves.get(rightSegment), null, sentenceParent, null);
		}
	}

	private XdmNode deepestAncestorOf(List<Leaf> leaves, int from, int to) {

		if (from == to) {
			//it can return null if the segment is added to help the Lexer
			return leaves.get(from).formatting;
		}

		int minLevel = Integer.MAX_VALUE;
		for (int k = from; k <= to; ++k)
			if (leaves.get(k).level < minLevel
			        && leaves.get(k).formatting != null)
				minLevel = leaves.get(k).level;

		XdmNode[] all = new XdmNode[leaves.size()];
		int size = 0;
		for (int i = from; i <= to; ++i) {
			all[size] = leaves.get(i).formatting;
			if (all[size] != null) { //it can be null when the segment is added to help the Lexer
				for (int k = leaves.get(i).level - minLevel; k > 0; --k)
					all[size] = all[size].getParent();
				++size;
			}
		}

		while (true) {
			int i = 1;
			for (; i < size && same(all[i], all[0]); ++i);
			if (i >= size) {
				//ancestor found
				break;
			}
			for (i = 0; i < size; ++i)
				all[i] = all[i].getParent();
		}

		return all[0];
	}

	private static XdmNode getRoot(XdmNode node) {
		XdmSequenceIterator iter = node.axisIterator(Axis.CHILD);
		while (iter.hasNext()) {
			XdmNode n = (XdmNode) iter.next();
			if (n.getNodeKind() == XdmNodeKind.ELEMENT)
				return n;
		}
		return null;
	}

	private static boolean same(XdmNode n1, XdmNode n2) {
		return ((n1 == null && n2 == null) || (n1 != null && n2 != null && n1
		        .getUnderlyingNode().isSameNodeInfo(n2.getUnderlyingNode())));
	}

}
