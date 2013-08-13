package org.daisy.pipeline.nlp.breakdetect;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import net.sf.saxon.s9api.Axis;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmNodeKind;
import net.sf.saxon.s9api.XdmSequenceIterator;

import org.daisy.pipeline.nlp.LanguageUtils;
import org.daisy.pipeline.nlp.LanguageUtils.Language;
import org.daisy.pipeline.nlp.lexing.LexService;
import org.daisy.pipeline.nlp.lexing.LexService.LexerInitException;
import org.daisy.pipeline.nlp.lexing.LexService.Sentence;
import org.daisy.pipeline.nlp.lexing.LexService.TextReference;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.util.TreeWriter;

/**
 * Used to rebuild the input document with the additional xml elements resulting
 * from the lexing.
 */
public class XmlBreakRebuilder {

    private LexService mLexer;
    private XProcRuntime mRuntime;
    private FormatSpecifications mFormatSpecs;
    private long mMergeableID = 0;
    private boolean mSeenRoot;

    public XmlBreakRebuilder(XProcRuntime runtime, LexService lexer) {
        mRuntime = runtime;

        mLexer = lexer;
        try {
            mLexer.init();
        } catch (LexerInitException e) {
            e.printStackTrace();
        }
    }

    public void setFormatSpecifications(FormatSpecifications specs) {
        mFormatSpecs = specs;
    }

    public static XdmNode getFirstChild(XdmNode node) {
        XdmSequenceIterator iter = node.axisIterator(Axis.CHILD);
        if (iter.hasNext()) {
            return (XdmNode) iter.next();
        } else {
            return null;
        }
    }

    /**
     * Traverse recursively the sub-tree of an inline section to collect the
     * adjacent segments and the formatting info that will be needed both by the
     * lexer and the rebuilding step.
     */
    private void collectInlineSection(List<String> segments,
            List<XdmNode[]> inlineNodes, LinkedList<XdmNode> currentPath,
            XdmNode node, Language lang) {
        XdmSequenceIterator iter = node.axisIterator(Axis.CHILD);
        if (!iter.hasNext()) {
            String val = node.getStringValue();
            if (node.getNodeName() != null) {
                // case of <pagebreak/> for example
                currentPath.add(node);
                val = ""; // allow us to use substring() on it
            }

            XdmNode[] shallowCopy = new XdmNode[currentPath.size()];
            currentPath.toArray(shallowCopy);
            inlineNodes.add(shallowCopy);
            segments.add(val);

            if (node.getNodeName() != null)
                currentPath.removeLast(); // <pagebreak/>
        } else {
            currentPath.add(node);
            while (iter.hasNext()) {
                XdmNode child = (XdmNode) iter.next();
                collectInlineSection(segments, inlineNodes, currentPath, child,
                        lang);
            }
            currentPath.removeLast();
        }

        // inject temporary punctuations/spaces according to the context
        // for example, we may add a whitespace after every <span>
        if (node.getNodeName() != null) {
            String name = node.getNodeName().getLocalName();
            if (mFormatSpecs.spaceEquivalentElements.contains(name)) {
                inlineNodes.add(null);
                segments.add(LanguageUtils.getSpaceSymbol(lang));
            } else if (mFormatSpecs.commaEquivalentElements.contains(name)) {
                inlineNodes.add(null);
                segments.add(LanguageUtils.getCommaSymbol(lang));
            } else if (mFormatSpecs.periodEquivalentElements.contains(name)) {
                inlineNodes.add(null);
                segments.add(LanguageUtils.getPeriodSymbol(lang));
            } else if (mFormatSpecs.endOfSentenceElements.contains(name)) {
                inlineNodes.add(null);
                segments.add(LanguageUtils.getEndOfSentenceSymbol(lang));
            }
        }
    }

    /**
     * Add some text to the tree and wrapped it with a chain of XdmNodes.
     * 
     * @param wrapper
     *            is meant to be a list of formatting elements.
     */
    private void wrapText(TreeWriter tw, XdmNode[] wrapper, String text) {
        if (wrapper == null)
            return; // text should be an invisible delimiter

        for (int k = 0; k < wrapper.length; ++k) {
            tw.addStartElement(wrapper[k]);
            tw.addAttributes(wrapper[k]);
            // this attribute will be a criterion to know whether the node is
            // mergeable with other nodes with the same id. The id is icremented
            // for every new text segments
            tw.addAttribute(mFormatSpecs.mergeableAttr,
                    String.valueOf(mMergeableID));
        }
        if (text.length() > 0) {
            // text.length() = 0 for <pagebreak/>
            tw.addText(text);
        }
        for (int k = 0; k < wrapper.length; ++k)
            tw.addEndElement();
    }

    static class SegmentPos {
        int currentSegment;
        int charInSegment;
    }

    /**
     * Add the text and the elements between two positions.
     * 
     * @param pos
     *            is packed in a class to allow us to modify them
     */
    private void fillGap(SegmentPos pos, int untilSegment, int untilIndex,
            TreeWriter tw, ArrayList<String> segments,
            ArrayList<XdmNode[]> inlineNodes) {

        if (pos.currentSegment < untilSegment) {
            // complete the current segment if necessary
            if (pos.charInSegment != segments.get(pos.currentSegment).length())
                wrapText(
                        tw,
                        inlineNodes.get(pos.currentSegment),
                        segments.get(pos.currentSegment).substring(
                                pos.charInSegment));

            for (++pos.currentSegment, ++mMergeableID; pos.currentSegment < untilSegment; ++pos.currentSegment, ++mMergeableID) {
                wrapText(tw, inlineNodes.get(pos.currentSegment),
                        segments.get(pos.currentSegment));
            }
            pos.charInSegment = 0;
        }
        if (pos.charInSegment < untilIndex) {
            wrapText(
                    tw,
                    inlineNodes.get(pos.currentSegment),
                    segments.get(pos.currentSegment).substring(
                            pos.charInSegment, untilIndex));
            pos.charInSegment = untilIndex;
        }

    }

    /**
     * rebuild a single inline section using the results of the lexer
     */
    private void rebuildInlineSection(TreeWriter tw,
            ArrayList<String> segments, ArrayList<XdmNode[]> inlineNodes,
            List<Sentence> sentences) {

        SegmentPos pos = new SegmentPos();
        pos.charInSegment = 0;
        pos.currentSegment = 0;

        fillGap(pos, sentences.get(0).boundaries.firstSegment,
                sentences.get(0).boundaries.firstIndex, tw, segments,
                inlineNodes);

        for (Sentence s : sentences) {
            tw.addStartElement(mFormatSpecs.sentenceTag);
            if (mFormatSpecs.sentenceAttrVal != null
                    && !mFormatSpecs.sentenceAttrVal.equals("")) {
                tw.addAttribute(mFormatSpecs.sentenceAttr,
                        mFormatSpecs.sentenceAttrVal);
            }
            for (TextReference r : s.content) {

                fillGap(pos, r.firstSegment, r.firstIndex, tw, segments,
                        inlineNodes);

                // TODO: add proper nouns
                tw.addStartElement(mFormatSpecs.wordTag);
                if (mFormatSpecs.wordAttrVal != null
                        && !mFormatSpecs.wordAttrVal.equals("")) {
                    tw.addAttribute(mFormatSpecs.wordAttr,
                            mFormatSpecs.wordAttrVal);
                }

                fillGap(pos, r.lastSegment, r.lastIndex, tw, segments,
                        inlineNodes);

                tw.addEndElement(); // word tag
            }

            fillGap(pos, s.boundaries.lastSegment, s.boundaries.lastIndex, tw,
                    segments, inlineNodes);

            tw.addEndElement();// sentence tag
        }

    }

    /**
     * Lex an inline section and rebuild it.
     */
    private void tokenizeInlineSection(TreeWriter tw,
            List<XdmNode> inlineSection, Language currentLanguage) {
        // extract the text segments from the inlineSection
        // and a list of inlineNodes for each segment
        ArrayList<String> segments = new ArrayList<String>();
        ArrayList<XdmNode[]> inlineNodes = new ArrayList<XdmNode[]>();
        for (XdmNode subsection : inlineSection)
            collectInlineSection(segments, inlineNodes,
                    new LinkedList<XdmNode>(), subsection, currentLanguage);

        // call the tokenizer on the segments
        try {
            mLexer.useLanguage(currentLanguage);
        } catch (LexerInitException e) {
            e.printStackTrace();
        }
        List<Sentence> sentences = mLexer.split(segments);

        // rebuild the tree with the additional markups
        if (sentences.size() > 0)
            rebuildInlineSection(tw, segments, inlineNodes, sentences);
        else {
            // if there are not sentence, we just rebuild the XML exactly
            // like it was
            for (XdmNode subsection : inlineSection)
                tw.addSubtree(subsection);
        }
    }

    /**
     * Rebuild the whole tree, lexing the text on-the-fly. This step comes right
     * after the inline sections have been found.
     */
    private void rebuildFullTree(TreeWriter tw, XdmNode node,
            Set<XdmNode> inlineSections, Language currentLanguage) {
        if (inlineSections.contains(node)) {
            // this part of the tree will be built by tokenizeInlineSection()
            return;
        }

        String lang = node.getAttributeValue(mFormatSpecs.langAttr);
        if (lang != null) {
            Language x = LanguageUtils.stringToLanguage(lang);
            if (x != null)
                currentLanguage = x;
        }

        if (node.getNodeKind() == XdmNodeKind.PROCESSING_INSTRUCTION) {
            tw.addPI(node.getNodeName().getClarkName(), node.getStringValue());
        } else if (node.getNodeKind() == XdmNodeKind.COMMENT) {
            tw.addComment(node.getStringValue());
        } else if (node.getNodeKind() == XdmNodeKind.DOCUMENT) {
            tw.startDocument(node.getDocumentURI());
            XdmSequenceIterator iter = node.axisIterator(Axis.CHILD);
            while (iter.hasNext()) {
                XdmNode child = (XdmNode) iter.next();
                rebuildFullTree(tw, child, inlineSections, currentLanguage);
            }
            tw.endDocument();

        } else if (node.getNodeKind() == XdmNodeKind.ELEMENT) {
            tw.addStartElement(node);

            // this prevent the namespace from being repeated into children
            if (!mSeenRoot) {
                tw.addNamespace(mFormatSpecs.tmpNsPrefix, mFormatSpecs.tmpNsURI);
                mSeenRoot = true;
            }

            tw.addAttributes(node);

            LinkedList<XdmNode> concatSection = new LinkedList<XdmNode>();
            XdmSequenceIterator iter = node.axisIterator(Axis.CHILD);
            while (iter.hasNext()) {
                XdmNode child = (XdmNode) iter.next();
                if (inlineSections.contains(child)) {
                    concatSection.add(child);
                } else {
                    // end of the current inline section
                    if (concatSection.size() > 0) {
                        tokenizeInlineSection(tw, concatSection,
                                currentLanguage);
                        concatSection.clear();
                    }
                    rebuildFullTree(tw, child, inlineSections, currentLanguage);
                }
            }
            if (concatSection.size() > 0) {
                tokenizeInlineSection(tw, concatSection, currentLanguage);
            }
            tw.addEndElement();
        }
    }

    /**
     * Entry point of the rebuilder.
     */
    public XdmNode rebuild(XdmNode document, Set<XdmNode> inlineSections)
            throws SaxonApiException {

        TreeWriter tw = new TreeWriter(mRuntime);
        mSeenRoot = false;
        rebuildFullTree(tw, document, inlineSections, null);

        return tw.getResult();
    }
}