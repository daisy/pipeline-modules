package org.daisy.pipeline.nlp;

public class LanguageUtils {
    public enum Language {
        FRENCH,
        ENGLISH,
        GERMAN,
        POLISH,
        SPANISH,
        RUSSIAN,
        PORTUGUESE,
        DANISH,
        TURKISH,
        ITALIAN,
        NORWEGIAN,
        DUTCH,
        SWEDISH,
        HUNGARIAN,
        GREEK
    }

    public static Language stringToLanguage(String lang) {
        String lw = lang.toLowerCase();

        // these tags come from the IANA Language Subtag Registry
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
        }

        return res;
    }

    // one can customize the punctuations/space symbols depending on the
    // given language.

    public static String getPeriodSymbol(Language lang) {
        return ". ";
    }

    public static String getEndOfSentenceSymbol(Language lang) {
        return "? ";
    }

    public static String getCommaSymbol(Language lang) {
        return ", ";
    }

    public static String getSpaceSymbol(Language lang) {
        return " ";
    }
}
