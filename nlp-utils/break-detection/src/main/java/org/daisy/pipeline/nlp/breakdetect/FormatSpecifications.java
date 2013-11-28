package org.daisy.pipeline.nlp.breakdetect;

import java.util.Collection;
import java.util.Collections;
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
	public String tmpNsPrefix = "tmp";
	public QName langAttr;
	public Set<String> inlineElements;
	public Set<String> commaEquivalentElements;
	public Set<String> spaceEquivalentElements;
	public String tmpNs;

	FormatSpecifications(String tmpNamespace, String sentenceElement,
	        String wordElement, String langNamespace, String langAttr,
	        Collection<String> inlineElements,
	        Collection<String> commaEquivalentElements,
	        Collection<String> spaceEquivalentElements) {

		if (commaEquivalentElements == null)
			commaEquivalentElements = Collections.EMPTY_LIST;
		if (spaceEquivalentElements == null)
			spaceEquivalentElements = Collections.EMPTY_LIST;

		sentenceTag = new QName(tmpNamespace, sentenceElement);
		wordTag = new QName(tmpNamespace, wordElement);
		this.langAttr = new QName(langNamespace, langAttr);

		this.inlineElements = new HashSet<String>(inlineElements);
		this.inlineElements.addAll(commaEquivalentElements);

		this.commaEquivalentElements = new HashSet<String>(
		        commaEquivalentElements);
		this.spaceEquivalentElements = new HashSet<String>(
		        spaceEquivalentElements);

		this.tmpNs = tmpNamespace;
	}
}
