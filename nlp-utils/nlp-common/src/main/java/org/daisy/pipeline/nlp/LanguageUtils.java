package org.daisy.pipeline.nlp;

public class LanguageUtils {
	public enum Language {
		FRENCH, ENGLISH, GERMAN, POLISH, SPANISH, RUSSIAN, PORTUGUESE, DANISH, TURKISH, ITALIAN, NORWEGIAN, DUTCH, SWEDISH, HUNGARIAN, GREEK, ARABIC, HEBREW, YIDDISH, PERSIAN, CHINESE, JAPANESE, KOREAN, HINDI
	}

	public static Language stringToLanguage(String lang) {
		String lw = lang.toLowerCase();

		// these tags come from the IANA Language Subtag Registry
		//TODO: a map with all the different codes that does not share any common prefix
		//(like ja and jpn for Japanese)
		Language res = null;
		if (lw.startsWith("fr")) {
			res = Language.FRENCH;
		} else if (lw.startsWith("en")) {
			res = Language.ENGLISH;
		} else if (lw.startsWith("de")) {
			res = Language.GERMAN;
		} else if (lw.startsWith("pl")) {
			res = Language.POLISH;
		} else if (lw.startsWith("es")) {
			res = Language.SPANISH;
		} else if (lw.startsWith("ru")) {
			res = Language.RUSSIAN;
		} else if (lw.startsWith("pt")) {
			res = Language.PORTUGUESE;
		} else if (lw.startsWith("da")) {
			res = Language.DANISH;
		} else if (lw.startsWith("tr")) {
			res = Language.TURKISH;
		} else if (lw.startsWith("it")) {
			res = Language.ITALIAN;
		} else if (lw.startsWith("no")) {
			res = Language.NORWEGIAN;
		} else if (lw.startsWith("nl")) {
			res = Language.DUTCH;
		} else if (lw.startsWith("sv")) {
			res = Language.SWEDISH;
		} else if (lw.startsWith("hu")) {
			res = Language.HUNGARIAN;
		} else if (lw.startsWith("el")) {
			res = Language.GREEK;
		} else if (lw.startsWith("fa")) {
			res = Language.PERSIAN;
		} else if (lw.startsWith("yi")) {
			res = Language.YIDDISH;
		} else if (lw.startsWith("ar")) {
			res = Language.ARABIC;
		} else if (lw.startsWith("zh")) {
			res = Language.CHINESE;
		} else if (lw.startsWith("ko")) {
			res = Language.KOREAN;
		} else if (lw.startsWith("hi")) {
			res = Language.HINDI;
		} else if (lw.startsWith("ja") || lw.equals("jpn")) {
			res = Language.JAPANESE;
		}

		return res;
	}

	public static boolean isRightToLeft(Language l) {
		return (l == Language.YIDDISH || l == Language.ARABIC
		        || l == Language.HEBREW || l == Language.PERSIAN);
	}

	// one can customize the punctuation/space symbols depending on the
	// given language.

	public static String getFullStopLeftSymbol(Language lang) {
		if (isRightToLeft(lang))
			return " !";
		return "";
	}

	public static String getCommaLeftSymbol(Language lang) {
		if (isRightToLeft(lang))
			return " ,";
		return "";
	}

	public static String getFullStopRightSymbol(Language lang) {
		if (isRightToLeft(lang))
			return "";
		return "! ";
	}

	public static String getCommaRightSymbol(Language lang) {
		if (isRightToLeft(lang))
			return "";
		return ", ";
	}

	public static String getWhiteSpaceSymbol(Language lang) {
		return " ";
	}
}
