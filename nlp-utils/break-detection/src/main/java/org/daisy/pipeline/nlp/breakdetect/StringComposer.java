package org.daisy.pipeline.nlp.breakdetect;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.daisy.pipeline.nlp.lexing.LexService.Sentence;
import org.daisy.pipeline.nlp.lexing.LexService.TextBoundaries;

/**
 * This class transforms references to a single string (i.e. two indexes) into a
 * list of references to an array of strings (i.e. a list of four indexes). It
 * is used for splitting XML content (array of strings) with the LexService
 * interface (single string inputs).
 */
public class StringComposer {

	static public class TextPointer {
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

	static public class SentencePointer {
		public TextPointer boundaries;
		public List<TextPointer> content; //optional
	}

	private List<SentencePointer> mSentencePointers = new ArrayList<SentencePointer>();
	private List<TextPointer> mWordPointers = new ArrayList<TextPointer>();
	private int[] mCoordinates = new int[2];

	public String concat(Collection<String> segments) {
		StringBuilder sb = new StringBuilder();
		for (String segment : segments) {
			if (segment != null)
				sb.append(segment);
		}
		return sb.toString();
	}

	/**
	 * The result cannot be kept after another call as it might be recycled.
	 */
	public List<SentencePointer> makePointers(List<Sentence> sentences, List<String> segments) {
		int totalSize = 0;
		for (Sentence s : sentences)
			if (s.words != null)
				totalSize += s.words.size();
		for (int size = mWordPointers.size(); size < totalSize; ++size)
			mWordPointers.add(new TextPointer());

		int contentIndex = 0;
		int[] coord;
		for (int i = 0; i < sentences.size(); ++i) {
			if (mSentencePointers.size() == i) {
				SentencePointer sp = new SentencePointer();
				sp.boundaries = new TextPointer();
				mSentencePointers.add(sp);
			}
			Sentence sentence = sentences.get(i);
			SentencePointer sp = mSentencePointers.get(i);

			coord = findLeft(segments, sentence.boundaries.left);
			sp.boundaries.firstSegment = coord[0];
			sp.boundaries.firstIndex = coord[1];

			coord = findRight(segments, sentence.boundaries.right);
			sp.boundaries.lastSegment = coord[0];
			sp.boundaries.lastIndex = coord[1];

			if (sentence.words == null || sentence.words.size() == 0) {
				sp.content = null;
			} else {
				int contentLeft = contentIndex;
				for (int j = 0; j < sentence.words.size(); ++j, ++contentIndex) {
					TextBoundaries word = sentence.words.get(j);
					TextPointer tp = mWordPointers.get(contentIndex);

					coord = findLeft(segments, word.left);
					tp.firstSegment = coord[0];
					tp.firstIndex = coord[1];

					coord = findRight(segments, word.right);
					tp.lastSegment = coord[0];
					tp.lastIndex = coord[1];
				}
				sp.content = mWordPointers.subList(contentLeft, contentIndex);
			}
		}

		return mSentencePointers.subList(0, sentences.size());
	}

	private int[] findLeft(List<String> segments, int index) {
		return findInArray(segments, index);
	}

	private int[] findRight(List<String> segments, int index) {
		int[] res = findInArray(segments, index - 1);
		res[1] += 1;
		return res;
	}

	private int[] findInArray(List<String> segments, int index) {
		mCoordinates[0] = 0;
		while ((segments.get(mCoordinates[0]) == null)
		        || (index >= segments.get(mCoordinates[0]).length())) {
			if (segments.get(mCoordinates[0]) != null)
				index -= segments.get(mCoordinates[0]).length();
			++mCoordinates[0];
		}
		mCoordinates[1] = index;
		return mCoordinates;
	}
}
