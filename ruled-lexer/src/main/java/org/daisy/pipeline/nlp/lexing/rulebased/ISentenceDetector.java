package org.daisy.pipeline.nlp.lexing.rulebased;

import java.util.List;

import org.daisy.pipeline.nlp.TextCategorizer.CategorizedWord;

public interface ISentenceDetector {

	/**
	 * The result cannot be kept after another call as it might be recycled.
	 * 
	 * @return a list of sentences.
	 */
	List<List<CategorizedWord>> split(List<CategorizedWord> words);

	boolean threadsafe();
}
