package org.daisy.pipeline.nlp.lexing.omni;

import java.text.BreakIterator;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.daisy.pipeline.nlp.lexing.GenericLexService;

/**
 * This is a multi-language lexer that does not support the following features:
 * 
 * - Word segmentation ;
 * 
 * - Period-based sentence segmentation (periods can be ambiguous).
 */
public class OmnilangLexer implements GenericLexService {

	private BreakIterator mSentIterator;
	private BreakIterator mWordIterator;
	private Matcher mWordMatcher;
	private Matcher mSpaceMatcher;

	@Override
	public void init() throws LexerInitException {
		mWordMatcher = Pattern.compile("[^\\p{P}\\s\\p{Z}\\p{C}]", Pattern.MULTILINE).matcher(
		        "");
		mSpaceMatcher = Pattern.compile("[\\p{Z}\\s]+", Pattern.MULTILINE).matcher("");
	}

	@Override
	public void cleanUpLangResources() {
		mSentIterator = null;
		mWordIterator = null;
		mWordMatcher = null;
	}

	@Override
	public void useLanguage(Locale lang) throws LexerInitException {
		if (lang == null) {
			mSentIterator = BreakIterator.getSentenceInstance();
			mWordIterator = BreakIterator.getWordInstance();
		} else {
			mSentIterator = BreakIterator.getSentenceInstance(lang);
			mWordIterator = BreakIterator.getWordInstance(lang);
		}
	}

	@Override
	public List<Sentence> split(String input) {
		if (input.length() == 0)
			return Collections.EMPTY_LIST;

		mSpaceMatcher.reset(input);
		if (mSpaceMatcher.matches())
			return Collections.EMPTY_LIST;

		List<Sentence> result = new ArrayList<Sentence>();

		//replace "J.J.R. Tolkien" with "J.J.RA Tolkien"
		input = input.replaceAll("(\\p{Lu})(([.]\\p{Lu})+)[.](?=[\n ]\\p{Lu})", "$1$2A");

		mSentIterator.setText(input);
		int start = mSentIterator.first();
		for (int end = mSentIterator.next(); end != BreakIterator.DONE; start = end, end = mSentIterator
		        .next()) {
			Sentence s = new Sentence();
			s.boundaries = new TextBoundaries();
			s.boundaries.left = start;
			s.boundaries.right = end;
			s.words = new ArrayList<TextBoundaries>();
			result.add(s);

			//TODO: trim the white spaces?

			mWordIterator.setText(input.substring(start, end));
			int wstart = mWordIterator.first();
			for (int wend = mWordIterator.next(); wend != BreakIterator.DONE; wstart = wend, wend = mWordIterator
			        .next()) {

				int left = start + wstart;
				int right = start + wend;

				mWordMatcher.reset(input.substring(left, right));
				if (mWordMatcher.lookingAt()) {
					TextBoundaries tb = new TextBoundaries();
					tb.left = left;
					tb.right = right;
					s.words.add(tb);
				}
			}
		}

		return result;
	}

	@Override
	public int getLexQuality(Locale lang) {
		return GenericLexService.MinimalQuality;
	}

	@Override
	public String getName() {
		return "omnilang-lexer";
	}
}
