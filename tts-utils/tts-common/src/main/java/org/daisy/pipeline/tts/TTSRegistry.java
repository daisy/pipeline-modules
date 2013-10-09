package org.daisy.pipeline.tts;

import java.util.Collection;

import com.google.common.collect.LinkedHashMultimap;
import com.google.common.collect.Multimap;

public class TTSRegistry {

	private Multimap<String, TTSService> ttsServices = LinkedHashMultimap
	        .<String, TTSService> create();

	public TTSService getTTS(String preferredEngine, String lang) {
		int highestPriority = Integer.MIN_VALUE;
		TTSService best = null;
		Collection<TTSService> candidates = ttsServices.get(preferredEngine);
		if (candidates == null || candidates.size() == 0)
			candidates = ttsServices.values();

		for (TTSService s : candidates) {
			int p = s.getPriority(lang);
			if (p > highestPriority) {
				best = s;
				highestPriority = p;
			}
		}

		return best;
	}

	public void addTTS(TTSService tts) {
		ttsServices.put(tts.getName(), tts);
	}

	public void removeTTS(TTSService tts) {
		ttsServices.remove(tts.getName(), tts);
	}

}
