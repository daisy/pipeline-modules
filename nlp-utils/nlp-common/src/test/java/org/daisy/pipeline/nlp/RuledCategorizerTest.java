package org.daisy.pipeline.nlp;

import java.io.IOException;

import org.daisy.pipeline.nlp.TextCategorizer.CategorizedWord;
import org.daisy.pipeline.nlp.TextCategorizer.Category;
import org.daisy.pipeline.nlp.TextCategorizer.MatchMode;
import org.daisy.pipeline.nlp.ruledcategorizers.RuledMultilangCategorizer;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class RuledCategorizerTest {
	private TextCategorizer mCategorizer;

	@Before
	public void setUp() throws IOException {
		mCategorizer = new RuledMultilangCategorizer();
	}

	public CategorizedWord categorizeForPrefix(String x) throws IOException {
		mCategorizer.init(MatchMode.PREFIX_MATCH);
		CategorizedWord v = mCategorizer.categorize(x + " foo", x.toLowerCase());
		if (v == null) {
			v = new CategorizedWord();
			v.category = Category.UNKNOWN;
			v.word = "";
		}
		return v;
	}

	@Test
	public void date1() throws IOException {
		String date = "2008-12-24";
		CategorizedWord w = categorizeForPrefix(date);
		Assert.assertEquals(date, w.word);
		Assert.assertEquals(Category.DATE, w.category);
	}

	@Test
	public void date2() throws IOException {
		String date = "30/07/2002";
		CategorizedWord w = categorizeForPrefix(date);
		Assert.assertEquals(date, w.word);
		Assert.assertEquals(Category.DATE, w.category);
	}

	@Test
	public void date3() throws IOException {
		String date = "08/1982";
		CategorizedWord w = categorizeForPrefix(date);
		Assert.assertEquals(date, w.word);
		Assert.assertEquals(Category.DATE, w.category);
	}

	@Test
	public void not_date2() throws IOException {
		String d = "1998-20-18";
		CategorizedWord w = categorizeForPrefix(d);
		Assert.assertFalse(w.category == Category.DATE && d.equals(w.word));
	}

	@Test
	public void not_date3() throws IOException {
		String d = "1998-11-42";
		CategorizedWord w = categorizeForPrefix(d);
		Assert.assertFalse(w.category == Category.DATE && d.equals(w.word));
	}

	@Test
	public void not_date4() throws IOException {
		CategorizedWord w = categorizeForPrefix("18/20/1998");
		Assert.assertNotSame(Category.DATE, w.category);
	}

	@Test
	public void not_date5() throws IOException {
		CategorizedWord w = categorizeForPrefix("42/11/1998");
		Assert.assertNotSame(Category.DATE, w.category);
	}

	@Test
	public void not_date6() throws IOException {
		String d = "00/10/1985";
		CategorizedWord w = categorizeForPrefix(d);
		Assert.assertFalse(w.category == Category.DATE && d.equals(w.word));
	}

	@Test
	public void not_date7() throws IOException {
		String d = "5/00/1985";
		CategorizedWord w = categorizeForPrefix(d);
		Assert.assertFalse(w.category == Category.DATE && d.equals(w.word));
	}

	@Test
	public void floatQuantity1() throws IOException {
		String f = "98.32";
		CategorizedWord w = categorizeForPrefix(f);
		Assert.assertEquals(f, w.word);
		Assert.assertEquals(Category.QUANTITY, w.category);
	}

	@Test
	public void floatQuantity2() throws IOException {
		String f = "24 198.32";
		CategorizedWord w = categorizeForPrefix(f);
		Assert.assertEquals(f, w.word);
		Assert.assertEquals(Category.QUANTITY, w.category);
	}

	@Test
	public void longQuantity1() throws IOException {
		String f = "321,154,757";
		CategorizedWord w = categorizeForPrefix(f);
		Assert.assertEquals(f, w.word);
		Assert.assertEquals(Category.QUANTITY, w.category);
	}

	@Test
	public void longQuantity2() throws IOException {
		String f = "321'154'757";
		CategorizedWord w = categorizeForPrefix(f);
		Assert.assertEquals(f, w.word);
		Assert.assertEquals(Category.QUANTITY, w.category);
	}

	@Test
	public void fakeQuantity1() throws IOException {
		CategorizedWord w = categorizeForPrefix("32 42");
		Assert.assertEquals("32", w.word);
		Assert.assertEquals(Category.QUANTITY, w.category);
	}

	@Test
	public void fakeQuantity2() throws IOException {
		CategorizedWord w = categorizeForPrefix("042");
		Assert.assertNotSame(Category.QUANTITY, w.category);
	}

	@Test
	public void latin() throws IOException {
		CategorizedWord w = categorizeForPrefix("a priori");
		Assert.assertEquals("a priori", w.word);
		Assert.assertEquals(Category.COMMON, w.category);
	}

	@Test
	public void currency1() throws IOException {
		String cur = "$35.02";
		CategorizedWord w = categorizeForPrefix(cur);
		Assert.assertEquals(cur, w.word);
		Assert.assertEquals(Category.CURRENCY, w.category);
	}

	@Test
	public void currency2() throws IOException {
		String cur = "35.02$";
		CategorizedWord w = categorizeForPrefix(cur);
		Assert.assertEquals(cur, w.word);
		Assert.assertEquals(Category.CURRENCY, w.category);
	}

	@Test
	public void emailaddr1() throws IOException {
		String email = "an.email@gmail.com";
		CategorizedWord w = categorizeForPrefix(email);
		Assert.assertEquals(email, w.word);
		Assert.assertEquals(Category.EMAIL_ADDR, w.category);
	}

	@Test
	public void emailaddr2() throws IOException {
		String email = "an.email(at)gmail.com";
		CategorizedWord w = categorizeForPrefix(email);
		Assert.assertEquals(email, w.word);
		Assert.assertEquals(Category.EMAIL_ADDR, w.category);
	}

	@Test
	public void not_emailaddr() throws IOException {
		String email = "an.email@_gmail.com";
		CategorizedWord w = categorizeForPrefix(email);
		Assert.assertNotSame(Category.EMAIL_ADDR, w.category);
	}

	@Test
	public void ftp() throws IOException {
		String l = "ftp://google.co.uk/to-to?a=b&_sessid=4547";
		CategorizedWord w = categorizeForPrefix(l);
		Assert.assertEquals(l, w.word);
		Assert.assertEquals(Category.WEB_LINK, w.category);
	}

	@Test
	public void multilang1() throws IOException {
		String l = "écrire-en-français";
		CategorizedWord w = categorizeForPrefix(l);
		Assert.assertEquals(l, w.word);
		Assert.assertEquals(Category.COMMON, w.category);
	}

	@Test
	public void time1() throws IOException {
		String l = "12:31";
		CategorizedWord w = categorizeForPrefix(l);
		Assert.assertEquals(l, w.word);
		Assert.assertEquals(Category.TIME, w.category);
	}
}
