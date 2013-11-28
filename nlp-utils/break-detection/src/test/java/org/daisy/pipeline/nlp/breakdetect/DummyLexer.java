package org.daisy.pipeline.nlp.breakdetect;

import java.util.ArrayList;
import java.util.List;

import org.daisy.pipeline.nlp.LanguageUtils.Language;
import org.daisy.pipeline.nlp.lexing.LexService;

public class DummyLexer implements LexService {

	public enum Strategy {
		ONE_SENTENCE, ONE_SEGMENT_ONE_SENTENCE, ONE_SEGMENT_ONE_WORD, ONE_SEGMENT_ONE_WORD_TRIMMED
	};

	public Strategy strategy = Strategy.ONE_SEGMENT_ONE_WORD;

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
	public List<Sentence> split(List<String> segments) {
		ArrayList<Sentence> result = new ArrayList<Sentence>();
		if (segments.size() == 0)
			return result;

		Sentence s;

		switch (strategy) {
		case ONE_SENTENCE:
		case ONE_SEGMENT_ONE_WORD:
		case ONE_SEGMENT_ONE_WORD_TRIMMED:
			if (strategy == Strategy.ONE_SEGMENT_ONE_WORD_TRIMMED) {
				ArrayList<String> segs = new ArrayList<String>();
				for (String seg : segments) {
					if (seg == null || seg.trim().isEmpty())
						segs.add(null);
					else
						segs.add(seg.trim());
				}
				segments = segs;
			}

			s = new Sentence();
			s.boundaries = new TextReference();
			s.content = null;
			s.boundaries.firstIndex = 0;
			for (s.boundaries.firstSegment = 0; s.boundaries.firstSegment < segments
			        .size() && segments.get(s.boundaries.firstSegment) == null; ++s.boundaries.firstSegment);
			if (s.boundaries.firstSegment < segments.size()) {
				s.boundaries.lastSegment = segments.size() - 1;
				for (s.boundaries.lastSegment = segments.size() - 1; segments
				        .get(s.boundaries.lastSegment) == null; --s.boundaries.lastSegment);
				s.boundaries.lastIndex = segments.get(s.boundaries.lastSegment)
				        .length();

				result.add(s);

				if (strategy == Strategy.ONE_SEGMENT_ONE_WORD) {
					s.content = new ArrayList<TextReference>();
					for (int i = 0; i < segments.size(); ++i) {
						if (segments.get(i) != null) {
							TextReference ref = new TextReference();
							ref.firstSegment = i;
							ref.firstIndex = 0;
							ref.lastSegment = i;
							ref.lastIndex = segments.get(ref.lastSegment)
							        .length();
							s.content.add(ref);
						}
					}
				}
			}

			break;
		case ONE_SEGMENT_ONE_SENTENCE:
			for (int i = 0; i < segments.size(); ++i) {
				if (segments.get(i) != null) {
					s = new Sentence();
					s.boundaries = new TextReference();
					s.content = null;
					s.boundaries.firstSegment = i;
					s.boundaries.firstIndex = 0;
					s.boundaries.lastSegment = i;
					s.boundaries.lastIndex = segments.get(
					        s.boundaries.lastSegment).length();
					result.add(s);
				}
			}

			break;
		}

		return result;
	}

}
