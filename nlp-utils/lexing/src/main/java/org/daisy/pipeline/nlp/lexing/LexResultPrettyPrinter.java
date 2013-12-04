package org.daisy.pipeline.nlp.lexing;

import java.util.List;

import org.daisy.pipeline.nlp.lexing.LexService.Sentence;
import org.daisy.pipeline.nlp.lexing.LexService.TextBoundaries;

/**
 * Convert one Lexer's result to formatted text. Likely to be used for testing.
 */
public class LexResultPrettyPrinter {

	private String mWordSeparator = "/";

	public void setWordSeperator(String wordSeparator) {
		mWordSeparator = wordSeparator;
	}

	public String convert(Object result, String lexerInput) {
		StringBuilder sb = new StringBuilder();
		dispatch(result, sb, lexerInput);
		return sb.toString();
	}

	private void dispatch(Object v, StringBuilder sb, String reference) {
		if (v instanceof List) {
			visit((List<Sentence>) v, sb, reference);
		} else if (v instanceof Sentence) {
			visit((Sentence) v, sb, reference);
		} else if (v instanceof TextBoundaries) {
			visit((TextBoundaries) v, sb, reference);
		}
	}

	private void visit(TextBoundaries t, StringBuilder sb, String reference) {
		sb.append(reference.substring(t.left, t.right));
	}

	private void visit(List<Sentence> sentences, StringBuilder sb,
	        String references) {
		for (Sentence s : sentences)
			dispatch(s, sb, references);
	}

	private void visit(Sentence s, StringBuilder sb, String reference) {
		sb.append("{");
		if (s.words == null || s.words.isEmpty()) {
			visit(s.boundaries, sb, reference);
		} else {
			int lastPos = s.boundaries.left;
			for (TextBoundaries word : s.words) {
				sb.append(reference.substring(lastPos, word.left));
				lastPos = word.right;
				sb.append(mWordSeparator);
				visit(word, sb, reference);
				sb.append(mWordSeparator);
			}
			sb.append(reference.substring(lastPos, s.boundaries.right));
		}
		sb.append("}");
	}
}
