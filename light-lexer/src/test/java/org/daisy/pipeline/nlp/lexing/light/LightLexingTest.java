package org.daisy.pipeline.nlp.lexing.light;

import java.util.Arrays;
import java.util.List;

import org.daisy.pipeline.nlp.LanguageUtils.Language;
import org.daisy.pipeline.nlp.lexing.LexResultPrettyPrinter;
import org.daisy.pipeline.nlp.lexing.LexService;
import org.daisy.pipeline.nlp.lexing.LexService.LexerInitException;
import org.daisy.pipeline.nlp.lexing.LexService.Sentence;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class LightLexingTest {

	LexResultPrettyPrinter mPrinter;
	LexService mTokenizer;

	@Before
	public void setUp() throws LexerInitException {
		mPrinter = new LexResultPrettyPrinter();
		mPrinter.displayAll(true);
		mTokenizer = new LightLexer();
		mTokenizer.init();
	}

	@Test
	public void twoSentences() throws LexerInitException {
		mTokenizer.useLanguage(Language.ENGLISH);

		String[] inp = new String[]{
			"first sentence! Second sentence"
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);

		Assert.assertEquals("[/first sentence!][/Second sentence]", text);
	}

	@Test
	public void twoBlocks() throws LexerInitException {
		mTokenizer.useLanguage(Language.ENGLISH);

		String[] inp = new String[]{
		        "firstblock", "secondblock"
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);
		Assert.assertEquals("[/firstblocksecondblock]", text);
	}

	@Test
	public void manyBlocks() throws LexerInitException {
		mTokenizer.useLanguage(Language.ENGLISH);

		String[] inp = new String[]{
		        "block. Start ", "end block start", "end"
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);

		Assert.assertEquals("[/block. Start end block startend]", text);
	}

	@Test
	public void spanish() throws LexerInitException {
		mTokenizer.useLanguage(Language.SPANISH);

		String[] inp = new String[]{
			"first sentence ¿ second sentence"
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);

		//the question mark is captured by the second sentence
		Assert.assertEquals("[/first sentence][/¿ second sentence]", text);
	}

	@Test
	public void mixed() throws LexerInitException {
		mTokenizer.useLanguage(Language.ENGLISH);
		String[] inp = new String[]{
			"first sentence !!... second sentence"
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);

		Assert.assertEquals("[/first sentence !!...][/second sentence]", text);
	}

	@Test
	public void malformed() throws LexerInitException {
		mTokenizer.useLanguage(Language.ENGLISH);
		String[] inp = new String[]{
			"!!! first sentence  ! second sentence"
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);

		Assert.assertEquals("[/!!! first sentence  !][/second sentence]", text);
	}

	@Test
	public void whitespaces1() throws LexerInitException {
		mTokenizer.useLanguage(Language.ENGLISH);
		String[] inp = new String[]{
			"first sentence !!  !! second sentence"
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);

		Assert.assertEquals("[/first sentence !!  !!][/second sentence]", text);
	}

	@Test
	public void whitespaces2() throws LexerInitException {
		mTokenizer.useLanguage(Language.SPANISH);
		String[] inp = new String[]{
			"first sentence !!  ¿¿ second sentence ?!"
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);

		Assert.assertEquals("[/first sentence !!][/¿¿ second sentence ?!]",
		        text);
	}

	@Test
	public void newline1() throws LexerInitException {
		mTokenizer.useLanguage(Language.ENGLISH);
		String[] inp = new String[]{
			"\n"
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);

		Assert.assertEquals("", text);
	}

	@Test
	public void newline2() throws LexerInitException {
		mTokenizer.useLanguage(Language.ENGLISH);
		String[] inp = new String[]{
			"\n  \n\n\n  \t\n "
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);

		Assert.assertEquals("", text);
	}

	@Test
	public void newline3() throws LexerInitException {
		mTokenizer.useLanguage(Language.ENGLISH);
		String[] inp = new String[]{
			"text text ? \t\n "
		};
		List<String> blocks = Arrays.asList(inp);

		List<Sentence> sentences = mTokenizer.split(blocks);

		String text = mPrinter.convert(sentences, blocks);

		Assert.assertEquals("[/text text ?]", text);
	}

}
