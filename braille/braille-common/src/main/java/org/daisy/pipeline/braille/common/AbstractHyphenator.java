package org.daisy.pipeline.braille.common;

import java.util.Arrays;
import java.util.regex.Pattern;

import com.google.common.base.Splitter;
import static com.google.common.collect.Iterables.toArray;

import static org.daisy.pipeline.braille.common.util.Strings.extractHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.insertHyphens;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.Strings.splitInclDelimiter;
import static org.daisy.pipeline.braille.common.util.Tuple2;

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

			@Override
			public String transform(String text) throws NonStandardHyphenationException {
				if (text.length() == 0)
					return text;
				Tuple2<String,byte[]> t = extractHyphens(text, isCodePointAware(), SHY, ZWSP);
				if (t._1.length() == 0)
					return text;
				return insertHyphens(t._1, transform(t._2, t._1), isCodePointAware(), SHY, ZWSP);
			}

			@Override
			public String[] transform(String text[]) throws NonStandardHyphenationException {
				Tuple2<String,byte[]> t = extractHyphens(join(text, US), isCodePointAware(), SHY, ZWSP);
				String[] unhyphenated = toArray(SEGMENT_SPLITTER.split(t._1), String.class);
				t = extractHyphens(t._2, t._1, isCodePointAware(), null, null, US);
				String _text = t._1;
				// This byte array is used not only to track the hyphen
				// positions but also the segment boundaries.
				byte[] positions = t._2;
				positions = transform(positions, _text);
				_text = insertHyphens(_text, positions, isCodePointAware(), SHY, ZWSP, US);
				if (text.length == 1)
					return new String[]{_text};
				else {
					String[] rv = new String[text.length];
					int i = 0;
					for (String s : SEGMENT_SPLITTER.split(_text)) {
						while (unhyphenated[i].length() == 0)
							rv[i++] = "";
						rv[i++] = s; }
					while(i < text.length)
						rv[i++] = "";
					return rv; }
			}

			/**
			 * @param manualHyphens      SHY and ZWSP characters that were extracted from the original
			 *                           text, which resulted in <code>textWithoutHyphens</code>
			 * @param textWithoutHyphens text without SHY and ZWSP characters
			 */
			protected byte[] transform(byte[] manualHyphens, String textWithoutHyphens) throws NonStandardHyphenationException {
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
				} else
					return getHyphenationOpportunities(textWithoutHyphens);
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
