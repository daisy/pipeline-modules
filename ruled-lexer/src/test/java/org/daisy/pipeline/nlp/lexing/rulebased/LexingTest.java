package org.daisy.pipeline.nlp.lexing.rulebased;

import java.util.Arrays;
import java.util.List;

import org.daisy.pipeline.nlp.LanguageUtils.Language;
import org.daisy.pipeline.nlp.lexing.LexResultPrettyPrinter;
import org.daisy.pipeline.nlp.lexing.LexService;
import org.daisy.pipeline.nlp.lexing.LexService.LexerInitException;
import org.daisy.pipeline.nlp.lexing.LexService.Sentence;
import org.daisy.pipeline.nlp.lexing.rulebased.RuleBasedLexer;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class LexingTest {

    LexResultPrettyPrinter mPrinter;
    LexService mTokenizer;

    @Before
    public void setUp() throws LexerInitException {
        mPrinter = new LexResultPrettyPrinter();
        mTokenizer = new RuleBasedLexer();
        mTokenizer.init();
    }

    @Test
    public void basicSplit() throws LexerInitException {
        mTokenizer.useLanguage(Language.ENGLISH);

        String[] inp = new String[] {
            "this is a   basic test"
        };
        List<String> blocks = Arrays.asList(inp);

        List<Sentence> sentences = mTokenizer.split(blocks);

        String text = mPrinter.convert(sentences, blocks);
        Assert.assertEquals("{/this/is/a/basic/test}", text);
    }

    @Test
    public void twoSentences() throws LexerInitException {
        mTokenizer.useLanguage(Language.ENGLISH);

        String[] inp = new String[] {
            "first sentence. Second sentence"
        };
        List<String> blocks = Arrays.asList(inp);

        List<Sentence> sentences = mTokenizer.split(blocks);

        String text = mPrinter.convert(sentences, blocks);
        Assert.assertEquals("{/first/sentence}{/Second/sentence}", text);
    }

    @Test
    public void twoSentences2() throws LexerInitException {
        mTokenizer.useLanguage(Language.ENGLISH);

        String[] inp = new String[] {
            "first sentence! Second sentence"
        };
        List<String> blocks = Arrays.asList(inp);

        List<Sentence> sentences = mTokenizer.split(blocks);

        String text = mPrinter.convert(sentences, blocks);
        Assert.assertEquals("{/first/sentence}{/Second/sentence}", text);
    }

    @Test
    public void capitalizedWords() throws LexerInitException {
        mTokenizer.useLanguage(Language.ENGLISH);

        String[] inp = new String[] {
            "Only One Sentence"
        };
        List<String> blocks = Arrays.asList(inp);

        List<Sentence> sentences = mTokenizer.split(blocks);

        String text = mPrinter.convert(sentences, blocks);
        Assert.assertEquals("{/Only/One/Sentence}", text);
    }

    @Test
    public void acronym1() throws LexerInitException {
        mTokenizer.useLanguage(Language.ENGLISH);

        String[] inp = new String[] {
            "test A.C.R.O.N.Y.M. other"
        };
        List<String> blocks = Arrays.asList(inp);

        List<Sentence> sentences = mTokenizer.split(blocks);

        String text = mPrinter.convert(sentences, blocks);
        Assert.assertEquals("{/test/A.C.R.O.N.Y.M./other}", text);
    }

    @Test
    public void acronym2() throws LexerInitException {
        mTokenizer.useLanguage(Language.ENGLISH);

        String[] inp = new String[] {
            "test A.C.R.O.N.Y.M. Other"
        };
        List<String> blocks = Arrays.asList(inp);

        List<Sentence> sentences = mTokenizer.split(blocks);

        String text = mPrinter.convert(sentences, blocks);
        Assert.assertEquals("{/test/A.C.R.O.N.Y.M}{/Other}", text);
    }

    @Test
    public void twoBlocks() throws LexerInitException {
        mTokenizer.useLanguage(Language.ENGLISH);

        String[] inp = new String[] {
                "firstblock", "secondblock"
        };
        List<String> blocks = Arrays.asList(inp);

        List<Sentence> sentences = mTokenizer.split(blocks);

        String text = mPrinter.convert(sentences, blocks);
        Assert.assertEquals("{/firstblocksecondblock}", text);
    }

    @Test
    public void manyBlocks() throws LexerInitException {
        mTokenizer.useLanguage(Language.ENGLISH);

        String[] inp = new String[] {
                "block. Start ", "end block start", "end"
        };
        List<String> blocks = Arrays.asList(inp);

        List<Sentence> sentences = mTokenizer.split(blocks);

        String text = mPrinter.convert(sentences, blocks);

        Assert.assertEquals("{/block}{/Start/end/block/startend}", text);
    }

    @Test
    public void httpAddress() throws LexerInitException {
        mTokenizer.useLanguage(Language.ENGLISH);

        String link = "http://www.google.fr/toto?a=b&_sessid=4547";
        String[] inp = new String[] {
            "before " + link + " after"
        };
        List<String> blocks = Arrays.asList(inp);

        List<Sentence> sentences = mTokenizer.split(blocks);

        String text = mPrinter.convert(sentences, blocks);

        Assert.assertEquals("{/before/" + link + "/after}", text);
    }

    @Test
    public void latin() throws LexerInitException {
        mTokenizer.useLanguage(Language.ENGLISH);

        String[] inp = new String[] {
            "a priori a posteriori"
        };
        List<String> blocks = Arrays.asList(inp);

        List<Sentence> sentences = mTokenizer.split(blocks);

        String text = mPrinter.convert(sentences, blocks);
        Assert.assertEquals("{/a priori/a posteriori}", text);
    }
}
