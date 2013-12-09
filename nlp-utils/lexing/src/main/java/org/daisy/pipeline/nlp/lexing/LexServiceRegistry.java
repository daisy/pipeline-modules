package org.daisy.pipeline.nlp.lexing;

import java.util.Collection;
import java.util.Locale;
import java.util.concurrent.CopyOnWriteArrayList;

public class LexServiceRegistry {
	private CopyOnWriteArrayList<LexService> mLexers = new CopyOnWriteArrayList<LexService>();
	private LexService mBestGenericLexer = null;

	public void addLexService(LexService lexer) {
		mLexers.add(lexer);
		synchronized (mLexers) {
			mLexers.notifyAll();
		}
	}

	public void removeLexService(LexService lexer) {
		mLexers.remove(lexer);
	}

	public void addGenericLexService(GenericLexService lexer) {
		if (mBestGenericLexer == null) {
			mBestGenericLexer = lexer;
		} else if (mBestGenericLexer.getLexQuality(null) < lexer.getLexQuality(null)) {
			mBestGenericLexer = lexer;
		}
	}

	public void removeGenericLexService(GenericLexService lexer) {
		if (mBestGenericLexer == lexer)
			mBestGenericLexer = null;
	}

	public LexService getBestGenericLexService() {
		return mBestGenericLexer;
	}

	private static final int Timeout = 10000; //10 seconds

	/**
	 * @param initializedLexers is a collection of already initialized lexers so
	 *            that if two lexers have the same score, the one already
	 *            initialized will be chosen.
	 */
	public LexService getLexerForLanguage(Locale lang, Collection<LexService> initializedLexers) {
		LexService best;
		while (true) {
			best = null;
			int bestScore = 1;
			for (LexService lexer : mLexers) {
				int score = lexer.getLexQuality(lang);
				if (score > bestScore
				        || (score == bestScore && initializedLexers.contains(lexer))) {
					bestScore = score;
					best = lexer;
				}
			}

			if (bestScore >= LexService.MinSpecializedLexQuality) {
				return best;
			}

			long time = System.currentTimeMillis();
			try {
				synchronized (mLexers) {
					mLexers.wait(Timeout + 100);
				}
			} catch (InterruptedException e) {
				return best;
			}
			if ((System.currentTimeMillis() - time) >= Timeout) {
				return best;
			}
		}
	}
}
