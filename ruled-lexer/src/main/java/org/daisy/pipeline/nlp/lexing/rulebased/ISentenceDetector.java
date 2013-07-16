package org.daisy.pipeline.nlp.lexing.rulebased;

import java.util.List;

import org.daisy.pipeline.nlp.TextCategorizer.CategorizedWord;

/**
 * Split into sentences. It must not discard anything, even spaces and
 * punctuation marks.
 */
public interface ISentenceDetector {

    List<List<CategorizedWord>> split(List<CategorizedWord> words);

}
