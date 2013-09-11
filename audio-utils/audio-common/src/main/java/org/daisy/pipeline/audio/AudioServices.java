package org.daisy.pipeline.audio;

import java.util.Collection;
import java.util.concurrent.CopyOnWriteArrayList;

import org.daisy.pipeline.audio.AudioEncoder;

public class AudioServices {

    private final Collection<AudioEncoder> encoders = new CopyOnWriteArrayList<AudioEncoder>();

    public AudioEncoder getEncoder() {
        return encoders.iterator().next();
    }

    public void addEncoder(AudioEncoder encoder) {
        encoders.add(encoder);
    }

    public void removeEncoder(AudioEncoder encoder) {
        encoders.remove(encoder);
    }

}