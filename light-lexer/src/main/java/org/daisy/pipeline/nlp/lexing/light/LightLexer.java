package org.daisy.pipeline.nlp.lexing.light;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.daisy.pipeline.nlp.LanguageUtils;
import org.daisy.pipeline.nlp.LanguageUtils.Language;
import org.daisy.pipeline.nlp.lexing.GenericLexService;

/**
 * This is a multi-language lexer that does not support the following features:
 * 
 * - Word segmentation ;
 * 
 * - Period-based sentence segmentation (periods can be ambiguous).
 */
public class LightLexer implements GenericLexService {

	private static String WhiteSpaces = " \t\r\n";
	private ArrayList<Integer> mStartPositions;

	private Matcher mEndMatcher;
	private Matcher mSepMatcher;
	private Matcher mSpaceMatcher;

	private void compileRegex(String startMarks, String endMarks) {
		Pattern p = Pattern.compile("(" + endMarks + "|[ \r\n\t\\p{Z}])+", Pattern.MULTILINE);
		mEndMatcher = p.matcher("");
		String allMarks = "((" + startMarks + ")|(" + endMarks + "))";
		p = Pattern.compile("(" + allMarks + "+[ \r\n\t\\p{Z}]+" + allMarks + "+)|("
		        + allMarks + "+)", Pattern.MULTILINE);
		mSepMatcher = p.matcher("");
	}

	@Override
	public void init() throws LexerInitException {
		mStartPositions = new ArrayList<Integer>(1);
		mStartPositions.add(0);
		mSpaceMatcher = Pattern.compile("[ \r\n\t\\p{Z}]+").matcher("");
	}

	@Override
	public void cleanUpLangResources() {
		mStartPositions = null;
		mSpaceMatcher = null;
		mEndMatcher = null;
	}

	@Override
	public void useLanguage(Language lang) throws LexerInitException {
		//Those are only examples. Feel free to customize them.
		if (LanguageUtils.isRightToLeft(lang)) {
			compileRegex("([؟…!?:׃])|([.][.][.])", "()");
		} else if (lang == Language.GREEK) {
			compileRegex("[¶]", "[:?!…;]|([.][.][.])"); //+ Greek semicolon
		} else if (lang == Language.CHINESE) {
			compileRegex("[¶]", "[:?!…;。]|([.][.][.])"); //+ Chinese full stop
		} else {
			compileRegex("[¡¿¶]", "[:?‥!…។៕]|([.][.][.])");
		}
	}

	public static void findInArray(List<String> segments, int index, int[] res) {
		res[0] = 0;
		while ((segments.get(res[0]) == null) || (index >= segments.get(res[0]).length())) {
			if (segments.get(res[0]) != null)
				index -= segments.get(res[0]).length();
			++res[0];
		}
		res[1] = index;
	}

	@Override
	public List<Sentence> split(String input) {
		if (input.length() == 0)
			return Collections.EMPTY_LIST;

		mSpaceMatcher.reset(input);
		if (mSpaceMatcher.matches()) {
			//otherwise it wouldn't work with the whitespace trimming below
			return Collections.EMPTY_LIST;
		}

		//find where the sentences starts (inclusive index)
		mSepMatcher.reset(input);
		int startIndex = 0;
		int lastIndex = 0;
		int sepNumber = 1;
		while (mSepMatcher.find()) {
			mEndMatcher.reset(mSepMatcher.group());
			startIndex = mSepMatcher.start();
			if (mEndMatcher.find()) {
				startIndex += mEndMatcher.end();
			}
			mSpaceMatcher.reset(input.subSequence(lastIndex, mSepMatcher.end()));
			lastIndex = mSepMatcher.end();
			if (mSpaceMatcher.matches() || mSepMatcher.start() == 0) {
				continue; //i.e. discard the sentence
			}
			if (sepNumber == mStartPositions.size())
				mStartPositions.add(0);

			mStartPositions.set(sepNumber++, startIndex);
		}
		mSpaceMatcher.reset(input.substring(mStartPositions.get(sepNumber - 1)));
		if (mStartPositions.get(sepNumber - 1) != input.length() && !mSpaceMatcher.matches()) {
			//add a virtual new sentence only if the sentence is not
			//already terminated by a separator and if the remaining text
			//is not made of white spaces only
			if (sepNumber == mStartPositions.size())
				mStartPositions.add(0);
			mStartPositions.set(sepNumber++, input.length());
		}

		ArrayList<Sentence> result = new ArrayList<Sentence>();
		for (int i = 0; i < sepNumber - 1; ++i) {
			int start = mStartPositions.get(i);
			int nextStart = mStartPositions.get(i + 1);

			//trim the white spaces
			while (WhiteSpaces.indexOf(input.charAt(start)) != -1)
				++start;
			while (WhiteSpaces.indexOf(input.charAt(nextStart - 1)) != -1)
				--nextStart;

			Sentence s = new Sentence();
			result.add(s);
			s.boundaries = new TextBoundaries();
			s.boundaries.left = start;
			s.boundaries.right = nextStart;
		}
		return result;
	}

	@Override
	public int getLexQuality(Language lang) {
		return GenericLexService.MinimalQuality;
	}

	@Override
	public String getName() {
		return "light-lexer";
	}
}
