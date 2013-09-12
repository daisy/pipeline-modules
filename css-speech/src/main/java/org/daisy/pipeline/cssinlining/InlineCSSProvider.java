package org.daisy.pipeline.cssinlining;

import org.daisy.common.xproc.calabash.XProcStepProvider;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.runtime.XAtomicStep;

public class InlineCSSProvider implements XProcStepProvider {

    @Override
    public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
        return new InlineCSSStep(runtime, step);
    }
}
