package org.daisy.pipeline.nlp;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

public class LanguageUtils {
	public static Locale stringToLanguage(String bcp47lang) {
		//TODO: in Java7 we would use:
		//return Locale.setLanguageTag(bcp47lang).build();
		//or with Locale.forLanguageTag(bcp47lang)

		String lw = bcp47lang.toLowerCase();

		Locale res = Locale.getDefault();
		if (lw.startsWith("fr")) {
			res = Locale.FRENCH;
		} else if (lw.startsWith("en")) {
			res = Locale.ENGLISH;
		} else if (lw.startsWith("de")) {
			res = Locale.GERMAN;
		} else if (lw.startsWith("it")) {
			res = Locale.ITALIAN;
		} else if (lw.startsWith("zh")) {
			res = Locale.CHINESE;
		} else if (lw.startsWith("ko")) {
			res = Locale.KOREAN;
		} else if (lw.startsWith("ja") || lw.equals("jpn")) {
			res = Locale.JAPANESE;
		}

		return res;
	}

	//lowercase ISO 639-2/T language codes (www.loc.gov/standards/iso639-2/php/English_list.php)
	private static Set<String> RightToLeft = new HashSet<String>(Arrays.asList("yid", "ara",
	        "jpr", "per", "fas", "peo", "heb"));

	public static boolean isRightToLeft(Locale l) {
		return RightToLeft.contains(l.getISO3Language());
	}

	// one can customize the punctuation/space symbols depending on the
	// given language.

	public static String getFullStopLeftSymbol(Locale lang) {
		return "";
	}

	public static String getCommaLeftSymbol(Locale lang) {
		return "";
	}

	public static String getFullStopRightSymbol(Locale lang) {
		return "! ";
	}

	public static String getCommaRightSymbol(Locale lang) {
		return ", ";
	}

	public static String getWhiteSpaceSymbol(Locale lang) {
		return " ";
	}
}
