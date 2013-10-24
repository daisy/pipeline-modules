package org.daisy.pipeline.tts;

import java.io.File;
import java.io.IOException;

import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.UnsupportedAudioFileException;

import org.daisy.pipeline.tts.TTSService.RawAudioBuffer;

public class SoundUtil {
	private static int MinRiffHeaderSize = 44;

	/**
	 * @return true if @param audioBuffer has been filled, false if @param
	 *         audioBuffer need to be flushed
	 */
	static public boolean readWave(File soundFile, RawAudioBuffer audioBuffer,
	        boolean twoTries) throws UnsupportedAudioFileException, IOException {
		int maxLength = (int) (soundFile.length() - MinRiffHeaderSize);
		boolean canFit = (soundFile.length() > (audioBuffer.output.length - audioBuffer.offsetInOutput));
		if (maxLength > audioBuffer.output.length || (!twoTries && !canFit)) {
			// the audio is not big enough => dynamic allocation
			audioBuffer.output = new byte[(int) maxLength];
			audioBuffer.offsetInOutput = 0;
		} else if (twoTries && canFit) {
			// the audio buffer is big enough but it needs to be flushed
			return false;
		}

		AudioInputStream fi = AudioSystem.getAudioInputStream(soundFile);
		int read = 0;
		while (audioBuffer.offsetInOutput + read != audioBuffer.output.length
		        && read != -1) {
			audioBuffer.offsetInOutput += read;
			read = fi.read(audioBuffer.output, audioBuffer.offsetInOutput,
			        audioBuffer.output.length - audioBuffer.offsetInOutput);
		}
		fi.close();

		return true;
	}
}
