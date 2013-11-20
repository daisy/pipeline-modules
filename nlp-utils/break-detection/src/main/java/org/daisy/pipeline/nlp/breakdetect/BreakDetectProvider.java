package org.daisy.pipeline.nlp.breakdetect;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.pipeline.nlp.lexing.LexService;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.runtime.XAtomicStep;

/**
 * OSGi component that provides an XProcStep on the top of a Lexer satisfied by
 * an OSGi service.
 */
public class BreakDetectProvider implements XProcStepProvider {

	private LexService mLexer = null;

	public void addLexer(LexService lexer) {
		mLexer = lexer;
	}

	public void removeLexer(LexService lexer) {
		mLexer = null;
	}

	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new BreakDetectStep(runtime, step, mLexer);
	}
}
