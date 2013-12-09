package org.daisy.pipeline.nlp.lexing.omni;

import java.util.List;
import java.util.Locale;

import org.daisy.pipeline.nlp.lexing.LexResultPrettyPrinter;
import org.daisy.pipeline.nlp.lexing.LexService;
import org.daisy.pipeline.nlp.lexing.LexService.LexerInitException;
import org.daisy.pipeline.nlp.lexing.LexService.Sentence;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

public class OmnilangTest {

	LexResultPrettyPrinter mPrinter;
	LexService mLexer;

	static Locale SPANISH;
	static Locale CHINESE;
	static Locale ARABIC;

	static {
		if (System.getProperty("java.version").startsWith("1.7.")) {
			SPANISH = new Locale("spa");
			CHINESE = new Locale("zho");
			ARABIC = new Locale("ara");
		} else {
			SPANISH = new Locale("es");
			CHINESE = new Locale("zh");
			ARABIC = new Locale("ar");
		}
	}

	@Before
	public void setUp() throws LexerInitException {
		mPrinter = new LexResultPrettyPrinter();
		mLexer = new OmnilangLexer();
		mLexer.init();
	}

	@Test
	public void twoSentences() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String ref = "first sentence! Second sentence";
		List<Sentence> sentences = mLexer.split(ref);
		String text = mPrinter.convert(sentences, ref);
		Assert.assertEquals("{/first/ /sentence/! }{/Second/ /sentence/}", text);
	}

	@Test
	public void mixed() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String ref = "first sentence !!... second sentence";
		List<Sentence> sentences = mLexer.split(ref);
		String text = mPrinter.convert(sentences, ref);
		Assert.assertEquals("{/first/ /sentence/ !!... }{/second/ /sentence/}", text);
	}

	@Ignore
	@Test
	public void whitespaces1() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String ref = "first sentence !!  !! second sentence";
		List<Sentence> sentences = mLexer.split(ref);
		String text = mPrinter.convert(sentences, ref);
		Assert.assertEquals("{/first/ /sentence/ !! !! }{/second/ /sentence/}", text);
	}

	@Test
	public void spanish1() throws LexerInitException {
		mLexer.useLanguage(SPANISH);
		String ref = "first sentence. ¿Second sentence?";
		List<Sentence> sentences = mLexer.split(ref);
		String text = mPrinter.convert(sentences, ref);
		Assert.assertEquals("{/first/ /sentence/. }{¿/Second/ /sentence/?}", text);
	}

	@Ignore
	@Test
	public void spanish2() throws LexerInitException {
		mLexer.useLanguage(SPANISH);
		String ref = "first sentence. ¿ Second sentence ?";
		List<Sentence> sentences = mLexer.split(ref);
		String text = mPrinter.convert(sentences, ref);
		Assert.assertEquals("{/first/ /sentence/. }{¿ /Second/ /sentence/ ?}", text);
	}

	@Test
	public void chinese() throws LexerInitException {
		mLexer.useLanguage(CHINESE);
		String ref = "我喜欢中国。我喜欢英语了。";
		List<Sentence> sentences = mLexer.split(ref);
		String text = mPrinter.convert(sentences, ref);

		Assert.assertEquals("{/我喜欢中国/。}{/我喜欢英语了/。}", text);
	}

	@Test
	public void newline() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String ref = "They do like\nJames.";
		List<Sentence> sentences = mLexer.split(ref);
		String text = mPrinter.convert(sentences, ref);

		Assert.assertEquals("{/They/ /do/ /like/\n/James/.}", text);
	}

	@Test
	public void abbr1() throws LexerInitException {
		mLexer.useLanguage(Locale.ENGLISH);
		String ref = "J.J.R. Tolkien";
		List<Sentence> sentences = mLexer.split(ref);
		String text = mPrinter.convert(sentences, ref);
		Assert.assertEquals("{/J.J.R./ /Tolkien/}", text);
	}

}
