package org.daisy.pipeline.tts;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.TTSService.Voice;

public class TTSRegistry {

	private List<TTSService> ttsServices;
	private Map<Voice, TTSService> mBestServices;
	private Map<String, Voice> mBestVoices; //for a given language
	private List<VoiceInfo> mVoicePriorities;

	private static class VoiceInfo {
		VoiceInfo(String voiceVendor, String voiceName, float priority,
		        String language) {
			this.voice = new Voice(voiceVendor, voiceName);
			this.priority = priority;
			this.language = language;
		}

		VoiceInfo(Voice v, float priority, String language) {
			this.voice = v;
			this.priority = priority;
			this.language = language;
		}

		Voice voice;
		float priority;
		String language;
	}

	private static String getPrefix(String language) {
		return language.split("[-_.]")[0];
	}

	public TTSRegistry() {
		ttsServices = new ArrayList<TTSService>();
		mVoicePriorities = new ArrayList<VoiceInfo>();
		for (String lang : new String[]{
		        "en", "fr", "es"
		}) {
			mVoicePriorities.add(new VoiceInfo("espeak", lang, 1, lang));
		}

		//French
		mVoicePriorities.add(new VoiceInfo("att", "alain16", 10, "fr"));
		mVoicePriorities.add(new VoiceInfo("att", "alain8", 7, "fr"));
		
		//English
		mVoicePriorities.add(new VoiceInfo("att", "mike16", 10, "en_us"));
		mVoicePriorities.add(new VoiceInfo("att", "mike8", 7, "en_us"));
		mVoicePriorities.add(new VoiceInfo("Microsoft", "Microsoft Anna", 4,
		        "en_us"));

		//TODO: override and add some from the system properties.
		//format: priority.vendor.voicename.language = priorityVal

		//copy the priorities with language variants removed
		List<VoiceInfo> shallowCpy = new ArrayList<VoiceInfo>(mVoicePriorities);
		for (VoiceInfo info : shallowCpy) {
			String shortLang = getPrefix(info.language);
			if (!shortLang.equals(info.language)) {
				mVoicePriorities.add(new VoiceInfo(info.voice,
				        info.priority - 0.1f, shortLang));
			}
		}

		Comparator<VoiceInfo> reverseComp = new Comparator<VoiceInfo>() {
			@Override
			public int compare(VoiceInfo v1, VoiceInfo v2) {
				return Float.valueOf(v2.priority).compareTo(
				        Float.valueOf(v1.priority));
			}
		};

		Collections.sort(mVoicePriorities, reverseComp);
	}

	public void regenerateVoiceMapping() {
		mBestServices = new HashMap<Voice, TTSService>();
		for (TTSService tts : ttsServices)
			try {
				List<Voice> voices = tts.getAvailableVoices();
				if (voices != null)
					for (Voice v : voices) {
						TTSService competitor = mBestServices.get(v);
						if (competitor == null
						        || competitor.getOverallPriority() < tts
						                .getOverallPriority())
							mBestServices.put(v, tts);
					}
			} catch (SynthesisException e) {
				//voices of this TTS Service are ignored
			}

		mBestVoices = new HashMap<String, Voice>();
		for (VoiceInfo voiceInfo : mVoicePriorities) {
			if (!mBestVoices.containsKey(voiceInfo.language)
			        && mBestServices.containsKey(voiceInfo.voice)){
				mBestVoices.put(voiceInfo.language, voiceInfo.voice);
			}
		}
	}

	public Voice findAvailableVoice(Voice preferredVoice, String lang) {
		if (mBestServices.containsKey(preferredVoice))
			return preferredVoice;
		return mBestVoices.get(lang);
	}

	/**
	 * @param voice is an available voice
	 * @return the best TTS Service for @param voice
	 */
	public TTSService getTTS(Voice voice) {
		return mBestServices.get(voice);
	}

	public void addTTS(TTSService tts) {
		ttsServices.add(tts);
	}

	public void removeTTS(TTSService tts) {
		ttsServices.remove(tts);
	}

}
