package org.daisy.pipeline.nlp.breakdetect;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

import net.sf.saxon.s9api.QName;

/**
 * Encapsulate what the Lexer needs to know about the input format so it can
 * parse and rebuild the input documents.
 */
public class FormatSpecifications {

    public QName sentenceTag;
    public QName wordTag;
    public QName nameTag;
    public QName langAttr;
    public Set<String> inlineElements;
    public Set<String> periodEquivalentElements;
    public Set<String> commaEquivalentElements;
    public Set<String> endOfSentenceElements;
    public Set<String> spaceEquivalentElements;

    FormatSpecifications(String outputNamespace, String sentenceElement,
            String wordElement, String nameElement, String langNamespace,
            String langAttr, Collection<String> inlineElements,
            Collection<String> periodEquivalentElements,
            Collection<String> commaEquivalentElements,
            Collection<String> endOfSentenceElements,
            Collection<String> spaceEquivalentElements) {

        sentenceTag = new QName(outputNamespace, sentenceElement);
        wordTag = new QName(outputNamespace, wordElement);
        nameTag = nameElement == null ? null : new QName(outputNamespace,
                nameElement);
        this.langAttr = new QName(langNamespace, langAttr);

        this.inlineElements = new HashSet<String>(inlineElements);
        this.inlineElements.addAll(periodEquivalentElements);
        this.inlineElements.addAll(commaEquivalentElements);
        this.inlineElements.addAll(endOfSentenceElements);

        this.periodEquivalentElements = new HashSet<String>(
                periodEquivalentElements);
        this.commaEquivalentElements = new HashSet<String>(
                commaEquivalentElements);
        this.endOfSentenceElements = new HashSet<String>(endOfSentenceElements);
        this.spaceEquivalentElements = new HashSet<String>(
                spaceEquivalentElements);
    }
}
