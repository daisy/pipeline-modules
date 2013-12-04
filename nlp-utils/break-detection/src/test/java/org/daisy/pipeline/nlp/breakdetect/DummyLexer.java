package org.daisy.pipeline.nlp.breakdetect;

import java.text.BreakIterator;
import java.util.ArrayList;
import java.util.List;

import org.daisy.pipeline.nlp.LanguageUtils.Language;
import org.daisy.pipeline.nlp.lexing.LexService;

public class DummyLexer implements LexService {

	public enum Strategy {
		ONE_SENTENCE, SPACE_SEPARARED_SENTENCES, SPACE_SEPARATED_WORDS, REGULAR
	};

	public Strategy strategy = Strategy.SPACE_SEPARATED_WORDS;

	@Override
	public int getLexQuality(Language lang) {
		return 1;
	}

	@Override
	public void init() throws LexerInitException {
	}

	@Override
	public void cleanUpLangResources() {
	}

	@Override
	public void useLanguage(Language lang) throws LexerInitException {
	}

	@Override
	public List<Sentence> split(String input) {
		ArrayList<Sentence> result = new ArrayList<Sentence>();
		if (input.isEmpty())
			return result;

		Sentence s;
		BreakIterator boundary;
		int start;

		switch (strategy) {
		case ONE_SENTENCE:
		case SPACE_SEPARATED_WORDS:
			s = new Sentence();
			s.boundaries = new TextBoundaries();
			s.words = null;
			s.boundaries.left = 0;
			s.boundaries.right = input.length();

			result.add(s);

			if (strategy == Strategy.SPACE_SEPARATED_WORDS) {
				s.words = new ArrayList<TextBoundaries>();
				boundary = BreakIterator.getWordInstance();
				boundary.setText(input.substring(s.boundaries.left));
				start = boundary.first();
				for (int end = boundary.next(); end != BreakIterator.DONE; start = end, end = boundary
				        .next()) {
					int p = start;
					for (; p < end
					        && !Character.isLetter(input.codePointAt(p + s.boundaries.left)); ++p);
					if (p < end) {
						TextBoundaries bounds = new TextBoundaries();
						bounds.left = start + s.boundaries.left;
						bounds.right = end + s.boundaries.left;
						s.words.add(bounds);
					}
				}
			}

			break;
		case SPACE_SEPARARED_SENTENCES:
			boundary = BreakIterator.getWordInstance();
			boundary.setText(input);
			start = boundary.first();
			for (int end = boundary.next(); end != BreakIterator.DONE; start = end, end = boundary
			        .next()) {

				int p = start;
				for (; p < end && !Character.isLetter(input.codePointAt(p)); ++p);

				if (p < end) {
					s = new Sentence();
					s.boundaries = new TextBoundaries();
					s.words = null;
					s.boundaries.left = start;
					s.boundaries.right = end;

					result.add(s);
				}
			}

			break;
		case REGULAR:
			boundary = BreakIterator.getSentenceInstance();
			boundary.setText(input);
			start = boundary.first();
			for (int end = boundary.next(); end != BreakIterator.DONE; start = end, end = boundary
			        .next()) {

				s = new Sentence();
				s.boundaries = new TextBoundaries();
				s.boundaries.left = start;
				s.boundaries.right = end;
				s.words = new ArrayList<TextBoundaries>();
				result.add(s);

				BreakIterator wb = BreakIterator.getWordInstance();
				wb.setText(input.substring(start, end));
				int wstart = wb.first();
				for (int wend = wb.next(); wend != BreakIterator.DONE; wstart = wend, wend = wb
				        .next()) {
					TextBoundaries tb = new TextBoundaries();
					tb.left = start + wstart;
					tb.right = start + wend;
					s.words.add(tb);
				}
			}

			break;
		}

		return result;
	}

	@Override
	public String getName() {
		return null;
	}
}
