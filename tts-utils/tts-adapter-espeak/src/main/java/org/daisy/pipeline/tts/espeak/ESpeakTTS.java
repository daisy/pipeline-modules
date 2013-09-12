package org.daisy.pipeline.tts.espeak;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.TTSService;

public class ESpeakTTS implements TTSService {

    @Override
    public AudioFormat getAudioOutputFormat() {
        return null;
    }

    @Override
    public Object synthesize(XdmNode ssml, RawAudioBuffer audioBuffer,
            Object caller, Object lastCallMemory) throws SynthesisException {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public String getName() {
        return "espeak";
    }

    @Override
    public int getPriority(String lang) {
        return -100;
    }

}
