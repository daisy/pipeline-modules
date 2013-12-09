package org.daisy.pipeline.nlp.lexing;

import java.util.List;
import java.util.Locale;

public interface LexService {

	public static final int MinSpecializedLexQuality = 10;

	public class LexerInitException extends Exception {
		public LexerInitException(String message, Throwable cause) {
			super(message, cause);
		}

		public LexerInitException(String message) {
			super(message);
		}
	}

	public class TextBoundaries {
		public int left; //inclusive
		public int right; //exclusive
	}

	public class Sentence {
		public List<TextBoundaries> words; //optional
		// this is necessary because the
		// punctuation marks and spaces are not
		// included in the content
		public TextBoundaries boundaries;
	}

	/**
	 * @return a score for the given language. The higher the better. Zero or
	 *         negative if the language is not supported.
	 */
	public int getLexQuality(Locale lang);

	/**
	 * @throws LexerInitException if the lexer failed to preload the data
	 *             attached to the languages
	 */
	void init() throws LexerInitException;

	/**
	 * This method must clean the resources allocated by init() and cached by
	 * useLanguage()
	 */
	public void cleanUpLangResources();

	/**
	 * @throws LexerInitException if the lexer failed to load the data attached
	 *             to @param lang in case it has not load them yet in init()
	 * 
	 */
	public void useLanguage(Locale lang) throws LexerInitException;

	public List<Sentence> split(String text);

	/**
	 * So far it is only used for logging.
	 */
	public String getName();
}
