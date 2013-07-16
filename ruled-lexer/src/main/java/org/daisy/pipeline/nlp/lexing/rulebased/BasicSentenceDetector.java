package org.daisy.pipeline.nlp.lexing.rulebased;

import java.util.LinkedList;
import java.util.List;
import java.util.regex.Pattern;

import org.daisy.pipeline.nlp.TextCategorizer.CategorizedWord;
import org.daisy.pipeline.nlp.TextCategorizer.Category;

/**
 * Dummy sentence detector based on the detection of combination of periods,
 * spaces and capitalized words.
 */
public class BasicSentenceDetector implements ISentenceDetector {
    Pattern mPossibleDelimiter;
    Pattern mSureDelimiter;

    public BasicSentenceDetector() {
        mPossibleDelimiter = Pattern.compile("[.:]+");
        mSureDelimiter = Pattern.compile("[.:?!]*[?!…]+[.:?!]*");
    }

    @Override
    public List<List<CategorizedWord>> split(
            List<CategorizedWord> CategorizedWords) {
        List<List<CategorizedWord>> result = new LinkedList<List<CategorizedWord>>();
        List<CategorizedWord> currentSentence = new LinkedList<CategorizedWord>();

        int delimiter = 0; // 2: sure, 1: possible, 0: no
        for (CategorizedWord w : CategorizedWords) {
            if (currentSentence.size() > 0
                    && w.category != Category.PUNCTUATION
                    && w.category != Category.SPACE
                    && (delimiter == 2 || (delimiter == 1
                            && w.category == Category.COMMON && Character
                                .isUpperCase(w.word.charAt(0))))) {
                result.add(currentSentence);
                currentSentence = new LinkedList<CategorizedWord>();
            }

            currentSentence.add(w);

            if (mSureDelimiter.matcher(w.word).matches()) {
                delimiter = 2;
            } else if (mPossibleDelimiter.matcher(w.word).matches()) {
                delimiter = 1;
            } else if (w.category != Category.SPACE)
                delimiter = 0;
        }

        if (currentSentence.size() > 0)
            result.add(currentSentence);

        return result;
    }
}
