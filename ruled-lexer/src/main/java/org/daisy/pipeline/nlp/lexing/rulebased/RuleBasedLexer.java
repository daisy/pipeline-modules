package org.daisy.pipeline.nlp.lexing.rulebased;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Locale;
import java.util.Map;

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
 * Keep the language resources (i.e. language-specific TextCategorizers) in
 * memory until it is explicitly requested to clean them up.
 */
public class RuleBasedLexer implements LexService {
	private ISentenceDetector mSentenceSplitter;
	private RuleBasedTextCategorizer mTextCategorizer;
	private RuleBasedTextCategorizer mGenericCategorizer = null;
	private ISentenceDetector mGenericSplitter = null;
	private Locale mCurrentLocale = null;

	private Map<Locale, ISentenceDetector> mSentenceSplitters;
	private Map<Locale, RuleBasedTextCategorizer> mTextCategorizers;

	@Override
	public void init() throws LexerInitException {
		mSentenceSplitters = new HashMap<Locale, ISentenceDetector>();
		mTextCategorizers = new HashMap<Locale, RuleBasedTextCategorizer>();
	}

	@Override
	public void cleanUpLangResources() {
		mSentenceSplitters.clear();
		mTextCategorizers.clear();
		mSentenceSplitter = null;
		mTextCategorizer = null;
		mGenericCategorizer = null;
		mGenericSplitter = null;
		mCurrentLocale = null;
	}

	@Override
	public void useLanguage(Locale lang) throws LexerInitException {
		if (!mTextCategorizers.containsKey(lang)) {
			try {
				RuleBasedTextCategorizer rtc;
				String iso639_2lang = lang.getISO3Language();
				if ("fre".equals(iso639_2lang) || "fra".equals(iso639_2lang)
				        || "frm".equals(iso639_2lang) || "fro".equals(iso639_2lang)) {
					rtc = new RuledFrenchCategorizer();
					rtc.init(MatchMode.PREFIX_MATCH);
				} else {
					if (mGenericCategorizer == null) {
						mGenericCategorizer = new RuledMultilangCategorizer();
						mGenericCategorizer.init(MatchMode.PREFIX_MATCH);
					}
					rtc = mGenericCategorizer;
				}
				mTextCategorizers.put(lang, rtc);

				ISentenceDetector isd;
				if (mGenericSplitter == null)
					mGenericSplitter = new EuroSentenceDetector();

				isd = mGenericSplitter;
				mSentenceSplitters.put(lang, isd);
			} catch (IOException e) {
				throw new LexerInitException(e.getMessage(), e.getCause());
			}
		}
		mSentenceSplitter = mSentenceSplitters.get(lang);
		mTextCategorizer = mTextCategorizers.get(lang);
		mCurrentLocale = lang;
	}

	public List<CategorizedWord> splitIntoWords(String input) {
		String lowerCase = input.toLowerCase(mCurrentLocale);
		LinkedList<CategorizedWord> result = new LinkedList<CategorizedWord>();

		int shift = 0;
		while (shift < input.length()) {
			String right = input.substring(shift);
			String lowerCaseRight = lowerCase.substring(shift);
			CategorizedWord w = mTextCategorizer.categorize(right, lowerCaseRight);
			result.add(w);
			shift += w.word.length();
		}

		return result;
	}

	@Override
	public List<Sentence> split(String input) {
		if (input.length() == 0)
			return Collections.EMPTY_LIST;

		// call the categorizer and the sentence detector
		List<CategorizedWord> words = splitIntoWords(input);
		if (words.size() == 0
		        || (words.size() == 1 && !TextCategorizer
		                .isSpeakable(words.iterator().next().category)))
			return Collections.EMPTY_LIST;

		List<List<CategorizedWord>> sentences = mSentenceSplitter.split(words);

		// build the sentences in the expected format
		int currentPos = 0;
		List<Sentence> res = new ArrayList<Sentence>();
		for (List<CategorizedWord> sentence : sentences) {
			//discard empty sentences
			int emptySize = 0;
			for (CategorizedWord word : sentence) {
				if (TextCategorizer.isSpeakable(word.category)) {
					emptySize = -1;
					break;
				}
				emptySize += word.word.length();
			}
			if (emptySize != -1) {
				currentPos += emptySize;
				continue;
			}

			Sentence s = new Sentence();
			s.boundaries = new TextBoundaries();
			res.add(s);

			//NOTE: Now, the StringComposer should already trim the sentences 

			//find the beginning of the sentence
			ListIterator<CategorizedWord> it = sentence.listIterator();
			while (it.hasNext()) {
				CategorizedWord word = it.next();
				if (word.category != Category.SPACE) {
					s.boundaries.left = currentPos;
					it.previous();
					break;
				}
				currentPos += word.word.length();
			}

			//content
			s.words = new ArrayList<LexService.TextBoundaries>();
			while (it.hasNext()) {
				CategorizedWord word = it.next();
				if (TextCategorizer.isSpeakable(word.category)) {
					TextBoundaries bounds = new TextBoundaries();
					bounds.left = currentPos;
					bounds.right = bounds.left + word.word.length();
					s.words.add(bounds);
				}
				currentPos += word.word.length();
			}

			//go backward to find the end of the sentence
			int end = currentPos;
			while (it.hasPrevious()) {
				CategorizedWord word = it.previous();
				if (word.category != Category.SPACE) {
					s.boundaries.right = end;
					break;
				}
				end -= word.word.length();
			}
		}

		return res;
	}

	@Override
	public int getLexQuality(Locale lang) {
		if (lang.getLanguage().equals(new Locale("en").getLanguage()))
			return 3 * LexService.MinSpecializedLexQuality;
		if (lang.getLanguage().equals(new Locale("fr").getLanguage()))
			return 3 * LexService.MinSpecializedLexQuality;
		return 0;
	}

	@Override
	public String getName() {
		return "rule-based-lexer";
	}

}
