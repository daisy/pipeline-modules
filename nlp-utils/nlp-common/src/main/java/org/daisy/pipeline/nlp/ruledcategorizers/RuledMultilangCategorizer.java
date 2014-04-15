package org.daisy.pipeline.nlp.ruledcategorizers;

import java.io.IOException;

import org.daisy.pipeline.nlp.RuleBasedTextCategorizer;
import org.daisy.pipeline.nlp.impl.matchrules.NumberRangeMatchRule;
import org.daisy.pipeline.nlp.impl.matchrules.RegexMatchRule;

public class RuledMultilangCategorizer extends RuleBasedTextCategorizer {

	public static int LOWEST_PRIORITY = 0;
	public static int COMMON_WORD_MAX_PRIORITY = 50;
	public static int SPACE_MAX_PRIORITY = 100;
	public static int QUOTE_MAX_PRIORITY = 125;
	public static int NUMBER_MAX_PRIORITY = 150;
	public static int REGEX_MAX_ACRONYM_PRIORITY = 160;
	public static int WEBLINK_MAX_PRIORITY = 300;
	public static int SPACE_COMPOSED_MAX_PRIORITY = 500;
	public static int NUMBER_COMPOSED_MAX_PRIORITY = 600;
	public static int DICTIONARY_MAX_PRIORITY = 700;
	protected static String CommonWordPattern = "[@\\p{L}][-_@\\p{L}\\p{Nd}]*";

	public RuledMultilangCategorizer() {

	}

	@Override
	public void init(MatchMode matchMode) throws IOException {
		super.init(matchMode);

		RegexMatchRule rsm;

		// ==== DATES ====
		String year = "([1-9][0-9]{1,3}|[0-9]{2})";
		String month = "(1[0-2]|0?[1-9])";
		String days = "(3[01]|[12]0|[0-2]?[1-9])";

		rsm = new RegexMatchRule(Category.DATE, NUMBER_COMPOSED_MAX_PRIORITY, true, mMatchMode);
		rsm.init(year + "-" + month + "-" + days + "(?![-\\p{L}\\p{Nd}])");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.DATE, NUMBER_COMPOSED_MAX_PRIORITY, true, mMatchMode);
		rsm.init(month + "-" + days + "(?![-\\p{L}\\p{Nd}])");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.DATE, NUMBER_COMPOSED_MAX_PRIORITY, true, mMatchMode);
		rsm.init(days + "/" + month + "/" + year + "(?![/\\p{L}\\p{Nd}])");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.DATE, NUMBER_COMPOSED_MAX_PRIORITY, true, mMatchMode);
		rsm.init(days + "/" + month + "(?![/\\p{L}\\p{Nd}])");
		addRule(rsm);

		addRule(new NumberRangeMatchRule(Category.RANGE, NUMBER_COMPOSED_MAX_PRIORITY,
		        mMatchMode));

		rsm = new RegexMatchRule(Category.DATE, NUMBER_COMPOSED_MAX_PRIORITY, true, mMatchMode);
		rsm.init(year + "-" + month + "(?![-\\p{L}\\p{Nd}])");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.DATE, NUMBER_COMPOSED_MAX_PRIORITY, true, mMatchMode);
		rsm.init(month + "/" + year + "(?![/\\p{L}\\p{Nd}])");
		addRule(rsm);

		// ==== TIME ====
		rsm = new RegexMatchRule(Category.TIME, NUMBER_COMPOSED_MAX_PRIORITY, true, mMatchMode);
		rsm.init("(2[0-4]|[01][0-9]):[0-6][0-9](?![0-9])");
		addRule(rsm);

		// TODO: more regexp for the time

		// ==== OTHER NUMBERS ====
		String integer = "([1-9]{1,3}([,' ][0-9]{3})+|[1-9][0-9]*)";
		String real = "(" + integer + "(\\.[0-9]+)?)";
		String currency = "([\\$€£₤¥]|usd|euro[s]?)";

		rsm = new RegexMatchRule(Category.DIMENSIONS, NUMBER_COMPOSED_MAX_PRIORITY, true,
		        mMatchMode);
		rsm.init(real + "(x|[ ]x[ ])" + real + "(?![\\p{L}\\p{Nd}])");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.CURRENCY, NUMBER_COMPOSED_MAX_PRIORITY, false,
		        mMatchMode);
		rsm.init(real + currency + "(?![\\p{L}\\p{Nd}])");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.CURRENCY, NUMBER_COMPOSED_MAX_PRIORITY, false,
		        mMatchMode);
		rsm.init(currency + real + "(?![\\p{L}\\p{Nd}])");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.NUMBERING_ITEM, NUMBER_COMPOSED_MAX_PRIORITY, false,
		        mMatchMode);
		rsm.init("[0-9]+([-.][0-9]+)*\\." + "(?![\\p{L}\\p{Nd}])");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.QUANTITY, NUMBER_MAX_PRIORITY, true, mMatchMode);
		rsm.init(real);
		addRule(rsm);

		rsm = new RegexMatchRule(Category.IDENTIFIER, NUMBER_MAX_PRIORITY - 1, true,
		        mMatchMode);
		rsm.init("[0-9]+([-_:][0-9]+)*" + "(?![\\p{L}\\p{Nd}])");
		addRule(rsm);

		// ==== SPACES ====
		rsm = new RegexMatchRule(Category.SPACE, SPACE_MAX_PRIORITY, true, mMatchMode);
		rsm.init("[\\p{Space} ]+");
		addRule(rsm);

		// ==== QUOTES ====
		rsm = new RegexMatchRule(Category.QUOTE, QUOTE_MAX_PRIORITY, true, mMatchMode);
		rsm.init("[\\p{Pf}\\p{Pi}\"']");
		addRule(rsm);

		// ==== SPECIAL STRINGS ====
		rsm = new RegexMatchRule(Category.WEB_LINK, WEBLINK_MAX_PRIORITY, true, mMatchMode);
		rsm.init("[a-z]+://[^\\p{Space}]*");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.WEB_LINK, WEBLINK_MAX_PRIORITY, true, mMatchMode);
		rsm.init("www\\.[^\\p{Space}]+");
		addRule(rsm);

		rsm = new RegexMatchRule(Category.EMAIL_ADDR, WEBLINK_MAX_PRIORITY, true, mMatchMode);
		rsm.init("[\\p{L}][-_.\\p{L}\\p{Nd}]*(@|\\(at\\))[\\p{L}][-_.\\p{L}\\p{Nd}]*");
		addRule(rsm);

		// ==== ACRONYMS ====

		String acronymPrefix = "[\\p{L}]\\.([-]?[\\p{L}\\p{Nd}]\\.)+";

		// acronyms terminated by a point that does not start a new sentence
		// with at least 2 components
		rsm = new RegexMatchRule(Category.ACRONYM, REGEX_MAX_ACRONYM_PRIORITY, true,
		        mMatchMode);
		rsm.init(acronymPrefix + "(?=[\\p{Space}]+[\\p{Ll}])");
		addRule(rsm);

		// acronyms not terminated by a point and at least 3 components
		rsm = new RegexMatchRule(Category.ACRONYM, REGEX_MAX_ACRONYM_PRIORITY, true,
		        mMatchMode);
		rsm.init(acronymPrefix + "[\\p{L}\\p{Nd}]");
		addRule(rsm);

		// ==== COMMON WORDS ====
		rsm = new RegexMatchRule(Category.COMMON, COMMON_WORD_MAX_PRIORITY, true, mMatchMode);
		rsm.init(CommonWordPattern);
		addRule(rsm);

		// ==== DEFAULT ====
		rsm = new RegexMatchRule(Category.PUNCTUATION, LOWEST_PRIORITY, true, mMatchMode);
		rsm.init(".");
		addRule(rsm);
	}
}
