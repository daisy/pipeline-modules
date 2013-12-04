package org.daisy.pipeline.nlp.lexing.rulebased;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.daisy.pipeline.nlp.TextCategorizer.CategorizedWord;
import org.daisy.pipeline.nlp.TextCategorizer.Category;

/**
 * Sentence detector suited for languages with sentences starting with a capital
 * letter after a white space and a proper punctuation mark.
 */
public class EuroSentenceDetector implements ISentenceDetector {
	private Matcher mStrongDelimiters;
	private Matcher mWeakDelimiters;
	private List<List<CategorizedWord>> mResult;
	private int mHead;
	private int mTail;
	private int mSentenceIndex;

	public EuroSentenceDetector() {
		mWeakDelimiters = Pattern.compile("[.:]+").matcher("");
		mStrongDelimiters = Pattern.compile("[.:?!]*[?!…]+[.:?!]*").matcher("");
		mResult = new ArrayList<List<CategorizedWord>>();
	}

	@Override
	public List<List<CategorizedWord>> split(List<CategorizedWord> words) {
		mHead = 0;
		mTail = 0;
		mSentenceIndex = 0;

		for (int j = 0; j < words.size(); ++j) {
			addWord();

			CategorizedWord w = words.get(j);
			mStrongDelimiters.reset(w.word);
			mWeakDelimiters.reset(w.word);

			if (mStrongDelimiters.matches()
			        || ((j < words.size() - 2) && mWeakDelimiters.matches()
			                && words.get(j + 1).category == Category.SPACE && Character
			                    .isUpperCase(words.get(j + 2).word.charAt(0)))) {
				newSentence(words);
			}
		}

		newSentence(words);

		return mResult.subList(0, mSentenceIndex);
	}

	private void newSentence(List<CategorizedWord> words) {
		if (mHead > mTail) {
			if (mSentenceIndex == mResult.size()) {
				mResult.add(null);
			}
			mResult.set(mSentenceIndex, words.subList(mTail, mHead));
			++mSentenceIndex;
			mTail = mHead;
		}
	}

	private void addWord() {
		++mHead;
	}
}
