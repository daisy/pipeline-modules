package org.daisy.pipeline.audio;

import java.io.File;
import java.time.Duration;

/**
 * Object that identifies a specific fragment in an audio file.
 */
public final class AudioClip {

	public final File file;
	public final Duration clipBegin;
	public final Duration clipEnd;

	public AudioClip(File file, Duration clipBegin, Duration clipEnd) {
		if (clipBegin == null || clipEnd == null || file == null)
			throw new NullPointerException();
		if (clipBegin.compareTo(Duration.ZERO) < 0)
			throw new IllegalArgumentException("Clip begin can not be negative");
		if (clipEnd.compareTo(clipBegin) < 0)
			throw new IllegalArgumentException("Clip end can not come before clip begin");
		this.file = file;
		this.clipBegin = clipBegin;
		this.clipEnd = clipEnd;
	}

	@Override
	public String toString() {
		return "[file: " + file + ", clipBegin: " + clipBegin + ", clipEnd: " + clipEnd + "]";
	}
}
