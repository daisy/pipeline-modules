package org.daisy.pipeline.audio;

import javax.sound.sampled.AudioFormat;

public interface AudioEncoder {
    /**
     * Encode raw audio data into a single file (mp3 for instance).
     * 
     * @param input
     *            are the audio data
     * @param size
     *            is the number of bytes of 'input' to be encoded
     * @param audioFormat
     *            tells how the data must be interpreted
     * 
     * @param caller
     *            is the Java object calling encode(). It can help making
     *            multi-threading strategies.
     * 
     * @param name
     *            will be the name of the sound file. If null, the choice of the
     *            name is left to the encoder.
     * @return the URI where the sound has been output
     */
    String encode(byte[] input, int size, AudioFormat audioFormat,
            Object caller, String name);
}
