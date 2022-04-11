package org.daisy.pipeline.braille.common;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

import com.google.common.base.Splitter;
import com.google.common.collect.Iterables;

import cz.vutbr.web.css.CSSProperty;

import org.daisy.braille.css.BrailleCSSProperty.Hyphens;
import org.daisy.braille.css.SimpleInlineStyle;
import static org.daisy.pipeline.braille.common.util.Strings.extractHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.insertHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.Strings.splitInclDelimiter;
import static org.daisy.pipeline.braille.common.util.Tuple2;
import org.daisy.pipeline.braille.css.CSSStyledText;

public abstract class AbstractHyphenator extends AbstractTransform implements Hyphenator {
	
	public FullHyphenator asFullHyphenator() throws UnsupportedOperationException {
		throw new UnsupportedOperationException();
	}
	
	public LineBreaker asLineBreaker() throws UnsupportedOperationException {
		throw new UnsupportedOperationException();
	}
	
	/* ================== */
	/*       UTILS        */
	/* ================== */
	
	public static abstract class util {
		
		private final static Pattern ON_SPACE_SPLITTER = Pattern.compile("\\s+");

		public static abstract class DefaultFullHyphenator implements FullHyphenator {

			/**
			 * Whether the length of the array returned by {@link
			 * #getHyphenationOpportunities()} is based on the number of code points in
			 * the input or the number of characters.
			 */
			protected abstract boolean isCodePointAware();

			/**
			 * Get hyphenation opportunities as a byte array (1 = SHY, 2 = ZWSP)
			 *
			 * @param textWithoutHyphens text that does not contain SHY and ZWSP characters (and from
			 *                           which no SHY and ZWSP characters were extracted either)
			 */
			protected abstract byte[] getHyphenationOpportunities(String textWithoutHyphens) throws NonStandardHyphenationException;

			private final static char SHY = '\u00AD';
			private final static char ZWSP = '\u200B';
			private final static char US = '\u001F';
			private final static Splitter SEGMENT_SPLITTER = Splitter.on(US);

			public Iterable<CSSStyledText> transform(Iterable<CSSStyledText> text) throws NonStandardHyphenationException {
				List<CSSStyledText> result = new ArrayList<>();
				List<CSSProperty> hyphenate = new ArrayList<>();
				boolean someHyphenate = false;
				for (CSSStyledText t : text) {
					t = t.clone();
					SimpleInlineStyle style = t.getStyle();
					CSSProperty h = style != null ? style.getProperty("hyphens") : null;
					if (h == null) h = Hyphens.MANUAL;
					hyphenate.add(h);
					if (h == Hyphens.AUTO)
						someHyphenate = true;
					if (style != null)
						style.removeProperty("hyphens");
					result.add(t);
				}
				if (result.size() == 0)
					return result;
				Tuple2<String,byte[]> t = extractHyphens(
					join(Iterables.transform(text, CSSStyledText::getText), US), isCodePointAware(), SHY, ZWSP);
				List<String> textWithoutHyphens = SEGMENT_SPLITTER.splitToList(t._1);
				t = extractHyphens(t._2, t._1, isCodePointAware(), null, null, US);
				String joinedTextWithoutHyphens = t._1;
				byte[] manualHyphensAndSegmentBoundaries = t._2;
				byte[] hyphensAndSegmentBoundaries = someHyphenate
					? transform(manualHyphensAndSegmentBoundaries, joinedTextWithoutHyphens)
					: manualHyphensAndSegmentBoundaries;
				List<String> textWithHyphens =
					SEGMENT_SPLITTER.splitToList(
						insertHyphens(
							joinedTextWithoutHyphens, hyphensAndSegmentBoundaries, isCodePointAware(), SHY, ZWSP, US));
				int i = 0;
				for (String s : textWithHyphens) {
					while (textWithoutHyphens.get(i).isEmpty()) {
						result.set(i, new CSSStyledText("", result.get(i).getStyle()));
						i++; }
					CSSProperty h = hyphenate.get(i);
					if (h == Hyphens.AUTO)
						result.set(i, new CSSStyledText(s, result.get(i).getStyle()));
					else if (h == Hyphens.NONE)
						result.set(i, new CSSStyledText(textWithoutHyphens.get(i), result.get(i).getStyle()));
					i++;
				}
				return result;
			}

			/**
			 * @param manualHyphens      SHY, ZWSP and US characters that were extracted from the original
			 *                           text, which resulted in <code>textWithoutHyphens</code>
			 * @param textWithoutHyphens text without SHY, ZWSP and US characters
			 */
			protected final byte[] transform(byte[] manualHyphens, String textWithoutHyphens) throws NonStandardHyphenationException {
				if (textWithoutHyphens.length() == 0)
					return manualHyphens;
				boolean hasManualHyphens = false; {
					if (manualHyphens != null)
						for (byte b : manualHyphens)
							if (b == (byte)1 || b == (byte)2) {
								hasManualHyphens = true;
								break; }}
				if (hasManualHyphens) {
					// input contains SHY or ZWSP; hyphenate only the words (sequences of non white space)
					// without SHY or ZWSP
					byte[] hyphens = Arrays.copyOf(manualHyphens, manualHyphens.length);
					boolean word = true;
					int pos = 0;
					for (String segment : splitInclDelimiter(textWithoutHyphens, ON_SPACE_SPLITTER)) {
						int len = isCodePointAware()
							? segment.codePointCount(0, segment.length())
							: segment.length();
						if (word && len > 0) {
							boolean wordHasManualHyphens = false; {
								for (int k = 0; k < len - 1; k++)
									if (hyphens[pos + k] != 0) {
										wordHasManualHyphens = true;
										break; }}
							if (!wordHasManualHyphens) {
								byte[] wordHyphens = getHyphenationOpportunities(segment);
								for (int k = 0; k < len - 1; k++)
									hyphens[pos + k] |= wordHyphens[k];
							}
						}
						pos += len;
						word = !word;
					}
					return hyphens;
				} else {
					byte[] hyphens = getHyphenationOpportunities(textWithoutHyphens);
					if (manualHyphens != null)
						for (int k = 0; k < hyphens.length; k++)
							hyphens[k] |= manualHyphens[k];
					return hyphens;
				}
			}
		}
		
		// TODO: caching?
		public static abstract class DefaultLineBreaker implements LineBreaker {
			
			protected abstract Break breakWord(String word, int limit, boolean force);
			
			protected static class Break {
				private final String text;
				private final int position;
				private final boolean hyphen;
				public Break(String text, int position, boolean hyphen) {
					this.text = text;
					this.position = position;
					this.hyphen = hyphen;
				}
				private String firstLine() {
					return text.substring(0, position);
				}
				private String secondLine() {
					return text.substring(position);
				}
				@Override
				public String toString() {
					return firstLine() + "=" + secondLine();
				}
			}
			
			public LineIterator transform(final String text) {
				
				return new LineIterator() {
					
					String remainder = text;
					String remainderAtMark = text;
					boolean lineHasHyphen = false;
					boolean lineHasHyphenAtMark = false;
					boolean started = false;
					boolean startedAtMark = false;
					
					public String nextLine(int limit, boolean force) {
						return nextLine(limit, force, true);
					}
					
					public String nextLine(int limit, boolean force, boolean allowHyphens) {
						started = true;
						String line = "";
						lineHasHyphen = false;
						if (remainder != null) {
							if (remainder.length() <= limit) {
								line += remainder;
								remainder = null; }
							else {
								String r = "";
								int available = limit;
								boolean word = true;
								for (String segment : splitInclDelimiter(remainder, ON_SPACE_SPLITTER)) {
									if (available == 0)
										r += segment;
									else if (segment.length() <= available) {
										line += segment;
										available -= segment.length();
										word = !word; }
									else if (word && allowHyphens) {
										Break brokenWord = breakWord(segment, available, force && (available == limit));
										line += brokenWord.firstLine();
										lineHasHyphen = brokenWord.hyphen;
										r += brokenWord.secondLine();
										available = 0; }
									else {
										r += segment;
										available = 0; }}
								remainder = r.isEmpty() ? null : r; }}
						return line;
					}
					
					public boolean hasNext() {
						return remainder != null;
					}
					
					public boolean lineHasHyphen() {
						if (!started)
							throw new RuntimeException("nextLine must be called first.");
						return lineHasHyphen;
					}
					
					public String remainder() {
						return remainder;
					}
					
					public void mark() {
						remainderAtMark = remainder;
						lineHasHyphenAtMark = lineHasHyphen;
						startedAtMark = started;
					}
					
					public void reset() {
						remainder = remainderAtMark;
						lineHasHyphen = lineHasHyphenAtMark;
						started = startedAtMark;
					}
				};
			}
		}
	}
}
