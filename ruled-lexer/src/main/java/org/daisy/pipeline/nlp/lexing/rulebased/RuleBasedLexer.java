package org.daisy.pipeline.nlp.lexing.rulebased;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.daisy.pipeline.nlp.LanguageUtils.Language;
import org.daisy.pipeline.nlp.RuleBasedTextCategorizer;
import org.daisy.pipeline.nlp.TextCategorizer;
import org.daisy.pipeline.nlp.TextCategorizer.CategorizedWord;
import org.daisy.pipeline.nlp.TextCategorizer.Category;
import org.daisy.pipeline.nlp.TextCategorizer.MatchMode;
import org.daisy.pipeline.nlp.lexing.LexService;
import org.daisy.pipeline.nlp.ruledcategorizers.RuledFrenchCategorizer;
import org.daisy.pipeline.nlp.ruledcategorizers.RuledMultilangCategorizer;

/**
 * Use a RuledBasedTextCategorizer in PREFIX_MODE to split the input stream into
 * words. Then call a SentenceDectector to group them together in sentences.
 * Keep the language resources (i.e. special TextCategorizer) in memory until it
 * is explicitly requested to clean them up.
 */
public class RuleBasedLexer implements LexService {
	private ISentenceDetector mSentenceSplitter;
	private RuleBasedTextCategorizer mTextCategorizer;
	private RuleBasedTextCategorizer mGenericCategorizer = null;
	private ISentenceDetector mGenericSplitter = null;

	private Map<Language, ISentenceDetector> mSentenceSplitters;
	private Map<Language, RuleBasedTextCategorizer> mTextCategorizers;

	@Override
	public void init() throws LexerInitException {
		mSentenceSplitters = new HashMap<Language, ISentenceDetector>();
		mTextCategorizers = new HashMap<Language, RuleBasedTextCategorizer>();
	}

	@Override
	public void cleanUpLangResources() {
		mSentenceSplitters.clear();
		mTextCategorizers.clear();
		mSentenceSplitter = null;
		mTextCategorizer = null;
		mGenericCategorizer = null;
		mGenericSplitter = null;
	}

	@Override
	public void useLanguage(Language lang) throws LexerInitException {
		if (!mTextCategorizers.containsKey(lang)) {
			try {
				RuleBasedTextCategorizer rtc;
				switch (lang) {
				case FRENCH:
					rtc = new RuledFrenchCategorizer();
					rtc.init(MatchMode.PREFIX_MATCH);
					break;
				default:
					if (mGenericCategorizer == null) {
						mGenericCategorizer = new RuledMultilangCategorizer();
						mGenericCategorizer.init(MatchMode.PREFIX_MATCH);
					}
					rtc = mGenericCategorizer;
					break;
				}
				mTextCategorizers.put(lang, rtc);

				ISentenceDetector isd;
				switch (lang) {
				default:
					if (mGenericSplitter == null)
						mGenericSplitter = new BasicSentenceDetector();

					isd = mGenericSplitter;
					break;
				}
				mSentenceSplitters.put(lang, isd);
			} catch (IOException e) {
				throw new LexerInitException(e.getMessage(), e.getCause());
			}
		}
		mSentenceSplitter = mSentenceSplitters.get(lang);
		mTextCategorizer = mTextCategorizers.get(lang);
	}

	public List<CategorizedWord> split(String input) {
		String lowerCase = input.toLowerCase();
		LinkedList<CategorizedWord> result = new LinkedList<CategorizedWord>();

		int shift = 0;
		while (shift < input.length()) {
			String right = input.substring(shift);
			String lowerCaseRight = lowerCase.substring(shift);
			CategorizedWord w = mTextCategorizer.categorize(right,
			        lowerCaseRight);
			result.add(w);
			shift += w.word.length();
		}

		return result;
	}

	@Override
	public List<Sentence> split(List<String> segments) {
		if (segments.size() == 0)
			return new ArrayList<Sentence>();

		// concatenate the input segments
		StringBuilder sb = new StringBuilder();
		for (String source : segments) {
			sb.append(source);
		}
		String input = sb.toString();

		// call the categorizer and the sentence detector
		List<CategorizedWord> words = split(input);
		if (words.size() == 0
		        || (words.size() == 1 && !TextCategorizer.isSpeakable(words
		                .iterator().next().category)))
			return new ArrayList<Sentence>();

		List<List<CategorizedWord>> sentences = mSentenceSplitter.split(words);

		// ===== build the result according to the to input segments =====
		// those variables are used to compute relative positions according to
		// the input segments
		int currentsegment = 0;
		int currentPos = 0;
		int segmentStart = 0; // inclusive index
		int segmentEnd = segments.get(currentsegment).length(); // exclusive
		                                                        // index

		// compose the output by creating pointers to the input segments
		// (the algorithm is a bit simpler than OpenNLPLexer
		// because the input is 100% covered by the words provided by
		// the splitter)
		LinkedList<Sentence> result = new LinkedList<Sentence>();
		for (List<CategorizedWord> sentence : sentences) {
			Sentence sentenceNode = new Sentence();
			result.add(sentenceNode);
			sentenceNode.content = new ArrayList<TextReference>();
			sentenceNode.boundaries = new TextReference();
			boolean first = true;

			TextReference ref = null;
			for (CategorizedWord w : sentence) {
				ref = new TextReference();
				if (w.category != Category.SPACE
				        && w.category != Category.PUNCTUATION)
					sentenceNode.content.add(ref);
				ref.properNoun = RuleBasedTextCategorizer
				        .isProperNoun(w.category);
				ref.firstSegment = currentsegment;
				ref.firstIndex = currentPos - segmentStart;
				if (first) {
					sentenceNode.boundaries.firstIndex = ref.firstIndex;
					sentenceNode.boundaries.lastIndex = ref.lastIndex;
					first = false;
				}

				// find where the token ends within the input segments
				currentPos += w.word.length();
				while (currentPos > segmentEnd) {
					++currentsegment;
					segmentStart = segmentEnd;
					segmentEnd += segments.get(currentsegment).length();
				}
				ref.lastSegment = currentsegment;
				ref.lastIndex = currentPos - segmentStart;
			}
			sentenceNode.boundaries.lastIndex = ref.lastIndex;
			sentenceNode.boundaries.lastSegment = ref.lastSegment;
		}

		return result;
	}

	@Override
	public int getLexQuality(Language lang) {
		if (lang == Language.ENGLISH)
			return 10;
		return 0;
	}

}
