package org.daisy.pipeline.nlp.breakdetect;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.pipeline.nlp.lexing.LexService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.runtime.XAtomicStep;

/**
 * OSGI component that provides an XProcStep on the top of a Lexer satisfied by
 * an OSGI service.
 */
public class BreakDetectProvider implements XProcStepProvider {

    private Logger mLogger = LoggerFactory.getLogger(BreakDetectProvider.class);
    private LexService mLexer = null; // here the Lexer is provided as an OSGI

    // service

    public void setLexer(LexService lexer) {
        mLogger.debug("set lexer service");
        mLexer = lexer;
    }

    public void unsetLexer(LexService lexer) {
        mLexer = null;
    }

    @Override
    public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
        mLogger.debug("ask for new break-detect step");
        return new BreakDetectStep(runtime, step, mLexer);
    }
}
