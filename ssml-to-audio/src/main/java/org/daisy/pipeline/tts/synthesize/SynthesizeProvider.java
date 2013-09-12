package org.daisy.pipeline.tts.synthesize;

import org.daisy.common.xproc.calabash.XProcStepProvider;
import org.daisy.pipeline.audio.AudioEncoder;
import org.daisy.pipeline.audio.AudioServices;
import org.daisy.pipeline.tts.TTSRegistry;

import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.core.XProcStep;
import com.xmlcalabash.runtime.XAtomicStep;

public class SynthesizeProvider implements XProcStepProvider {
	private TTSRegistry mRegistry;
	private AudioEncoder mEncoder;

	@Override
	public XProcStep newStep(XProcRuntime runtime, XAtomicStep step) {
		return new SynthesizeStep(runtime, step, mRegistry, mEncoder);
	}

	public void setTTSRegistry(TTSRegistry registry) {
		mRegistry = registry;
	}

	public void unsetTTSRegistry(TTSRegistry registry) {
		mRegistry = null;
	}

	public void setAudioServices(AudioServices audioServices) {
		// TODO: select an AudioService according to the user's preferences
		mEncoder = audioServices.getEncoder();
	}

	public void unsetAudioServices(Object encoder) {
		mEncoder = null;
	}
}
