package org.daisy.pipeline.nlp.lexing;

import java.util.List;

import org.daisy.pipeline.nlp.LanguageUtils.Language;

/**
 * A LexService is in charge of splitting the input text into sentences and each
 * sentence into words. The words may also be categorized (proper nouns...). In
 * order to handle the formatting info, which must not interfere with the
 * lexing, a lexer will have to process adjacent segments of text, instead of
 * single blocks, whose boundaries correspond to the location where the
 * formatting info are. Then the lexer will return references to the input
 * segments and let the caller rebuild everything with the formatting info.
 */
public interface LexService {

    class LexerInitException extends Exception {
        public LexerInitException(String message, Throwable cause) {
            super(message, cause);
        }

    }

    class TextReference {
        // inclusive index of the segment in which the first character is
        public int firstSegment;
        // inclusive index of the first character
        public int firstIndex;
        // inclusive index of the segment in which the last character is
        public int lastSegment;
        // EXLUSIVE index of the last character
        public int lastIndex;

        public boolean properNoun;
    }

    class Sentence {
        public TextReference boundaries; // this is necessary because the
                                         // punctuation marks and spaces are not
                                         // included in the content
        public List<TextReference> content;
    }

    /**
     * @throws LexerInitException
     *             if the lexer failed to preload the data attached to the
     *             languages
     */
    void init() throws LexerInitException;

    /**
     * This method must clean the resources allocated by init() and cached by
     * useLanguage()
     */
    public void cleanUpLangResources();

    /**
     * @throws LexerInitException
     *             if the lexer failed to load the data attached to @param lang
     *             in case it has not load them yet in init()
     * 
     */
    public void useLanguage(Language lang) throws LexerInitException;

    /**
     * Split the input strings into sentences that refer to the input segments.
     * 
     * @param segments
     *            are adjacent blocks of text. A word can be spread over
     *            multiple blocks.
     * @return a list of sentences referring to @param segments.
     */
    List<Sentence> split(List<String> segments);
}
