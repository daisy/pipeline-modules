package org.daisy.pipeline.nlp.lexing.rulebased;

import java.util.List;
import java.util.Locale;

import org.daisy.pipeline.nlp.lexing.LexResultPrettyPrinter;
import org.daisy.pipeline.nlp.lexing.LexService;
import org.daisy.pipeline.nlp.lexing.LexService.LexerInitException;
import org.daisy.pipeline.nlp.lexing.LexService.Sentence;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class LexingTest {

	private LexResultPrettyPrinter mPrinter;
	private LexService mLexer;

	@Before
	public void setUp() throws LexerInitException {
		mPrinter = new LexResultPrettyPrinter();
		mLexer = new RuleBasedLexer();
		mLexer.init();
	}

	@Test
	public void basicSplit() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String inp = "this is a   basic test";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);

		Assert.assertEquals("{/this/ /is/ /a/   /basic/ /test/}", text);
	}

	@Test
	public void twoSentences1() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String inp = "first sentence. Second sentence";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);

		Assert.assertEquals("{/first/ /sentence/.}{/Second/ /sentence/}", text);
	}

	@Test
	public void twoSentences2() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String inp = "first sentence! Second sentence";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);
		Assert.assertEquals("{/first/ /sentence/!}{/Second/ /sentence/}", text);
	}

	@Test
	public void capitalizedWords() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String inp = "Only One Sentence";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);
		Assert.assertEquals("{/Only/ /One/ /Sentence/}", text);
	}

	@Test
	public void acronym1() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String inp = "test A.C.R.O.N.Y.M. other";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);
		Assert.assertEquals("{/test/ /A.C.R.O.N.Y.M./ /other/}", text);
	}

	@Test
	public void acronym2() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String inp = "test A.C.R.O.N.Y.M. Other";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);
		Assert.assertEquals("{/test/ /A.C.R.O.N.Y.M/.}{/Other/}", text);
	}

	@Test
	public void httpAddress() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String link = "http://www.google.fr/toto?a=b&_sessid=4547";
		String inp = "before " + link + " after";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);
		Assert.assertEquals("{/before/ /" + link + "/ /after/}", text);
	}

	@Test
	public void latin() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String inp = "a priori a posteriori";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);
		Assert.assertEquals("{/a priori/ /a posteriori/}", text);
	}

	@Test
	public void whitespaces1() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String inp = "     sentence1.       Sentence2   ";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);
		Assert.assertEquals("{/sentence1/.}{/Sentence2/}", text);
	}

	@Test
	public void punctuationOnly1() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String inp = "sentence1! ??!!!  !! ? sentence2! ";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);
		Assert.assertEquals("{/sentence1/!}{/sentence2/!}", text);

	}

	@Test
	public void foreign() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String inp = "découpage basé sur des règles";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);
		Assert.assertEquals("{/découpage/ /basé/ /sur/ /des/ /règles/}", text);
	}

	@Test
	public void french1() throws LexerInitException {
		mLexer.useLanguage(Locale.FRENCH);
		String inp = "la raison d'être";
		List<Sentence> sentences = mLexer.split(inp);
		String text = mPrinter.convert(sentences, inp);
		Assert.assertEquals("{/la/ /raison/ /d'//être/}", text);
	}

	@Test
	public void brackets1() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String ref = "Bracket example (this is not a sentence!), after.";
		List<Sentence> sentences = mLexer.split(ref);
		String text = mPrinter.convert(sentences, ref);
		System.out.println("text = " + text);
		Assert.assertEquals(
		        "{/Bracket/ /example/ (/this/ /is/ /not/ /a/ /sentence/!), /after/.}", text);
	}
}
