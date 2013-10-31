package org.daisy.pipeline.tts;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.TTSService.Voice;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

// TODO: mark the voices as Male or Female and use this information when
// choosing a voice
public class TTSRegistry {

	private Logger mLogger = LoggerFactory.getLogger(TTSRegistry.class);
	private Map<TTSService, Boolean> ttsServices;
	private Map<String, TTSService> mVendors;
	private Map<Voice, TTSService> mBestServices;
	private Map<String, Voice> mBestVoices; //for a given language
	private static List<VoiceInfo> mVoicePriorities;

	public static class VoiceInfo {
		VoiceInfo(String voiceVendor, String voiceName, String language,
		        float priority) {
			this.voice = new Voice(voiceVendor, voiceName);
			this.language = language;
			this.priority = priority;
		}

		VoiceInfo(Voice v, String language, float priority) {
			this.voice = v;
			this.language = language;
			this.priority = priority;
		}

		@Override
		public int hashCode() {
			return this.voice.hashCode() ^ this.language.hashCode();
		}

		public boolean equals(Object other) {
			VoiceInfo o = (VoiceInfo) other;
			return voice.equals(o.voice) && language.equals(o.language);
		}

		public Voice voice;
		public String language;
		float priority;
	}

	private static String getPrefix(String language) {
		return language.split("[-_.]")[0];
	}

	static {
		final float priorityVariantPenalty = 0.1f;
		final String eSpeak = "espeak";
		final String att = "att";
		final String microsoft = "Microsoft";
		final int eSpeakPriority = 1;
		final int ATT16Priority = 10;
		final int ATT8Priority = 7;

		VoiceInfo[] info = {
		        //eSpeak:
		        new VoiceInfo(eSpeak, "french", "fr", eSpeakPriority),
		        new VoiceInfo(eSpeak, "danish", "da", eSpeakPriority),
		        new VoiceInfo(eSpeak, "german", "de", eSpeakPriority),
		        new VoiceInfo(eSpeak, "greek", "el", eSpeakPriority),
		        new VoiceInfo(eSpeak, "hindi", "hi", eSpeakPriority),
		        new VoiceInfo(eSpeak, "hungarian", "hu", eSpeakPriority),
		        new VoiceInfo(eSpeak, "finnish", "fi", eSpeakPriority),
		        new VoiceInfo(eSpeak, "italian", "it", eSpeakPriority),
		        new VoiceInfo(eSpeak, "latin", "la", eSpeakPriority),
		        new VoiceInfo(eSpeak, "norwegian", "no", eSpeakPriority),
		        new VoiceInfo(eSpeak, "polish", "pl", eSpeakPriority),
		        new VoiceInfo(eSpeak, "portugal", "pt", eSpeakPriority),
		        new VoiceInfo(eSpeak, "russian_test", "ru", eSpeakPriority),
		        new VoiceInfo(eSpeak, "swedish", "sv", eSpeakPriority),
		        new VoiceInfo(eSpeak, "mandarin", "zh", eSpeakPriority),
		        new VoiceInfo(eSpeak, "cantonese", "zh-yue", eSpeakPriority),
		        new VoiceInfo(eSpeak, "turkish", "tr", eSpeakPriority),
		        new VoiceInfo(eSpeak, "afrikaans", "af", eSpeakPriority),
		        new VoiceInfo(eSpeak, "spanish", "es", eSpeakPriority),
		        new VoiceInfo(eSpeak, "spanish-latin-american", "es-la",
		                eSpeakPriority),
		        new VoiceInfo(eSpeak, "english-us", "en", eSpeakPriority),
		        new VoiceInfo(eSpeak, "english-us", "en-us", eSpeakPriority),
		        new VoiceInfo(eSpeak, "english", "en-uk", eSpeakPriority),
		        //AT&T:
		        new VoiceInfo(att, "alain16", "fr", ATT16Priority),
		        new VoiceInfo(att, "alain8", "fr", ATT8Priority),
		        new VoiceInfo(att, "juliette16", "fr", ATT16Priority),
		        new VoiceInfo(att, "juliette8", "fr", ATT8Priority),
		        new VoiceInfo(att, "arnaud16", "fr-ca", ATT16Priority),
		        new VoiceInfo(att, "arnaud8", "fr-ca", ATT8Priority),
		        new VoiceInfo(att, "klara16", "de", ATT16Priority),
		        new VoiceInfo(att, "klara8", "de", ATT8Priority),
		        new VoiceInfo(att, "reiner16", "de", ATT16Priority),
		        new VoiceInfo(att, "reiner8", "de", ATT8Priority),
		        new VoiceInfo(att, "anjali16", "en-uk", ATT16Priority),
		        new VoiceInfo(att, "anjali8", "en-uk", ATT8Priority),
		        new VoiceInfo(att, "audrey16", "en-uk", ATT16Priority),
		        new VoiceInfo(att, "audrey8", "en-uk", ATT8Priority),
		        new VoiceInfo(att, "charles16", "en-uk", ATT16Priority),
		        new VoiceInfo(att, "charles8", "en-uk", ATT8Priority),
		        new VoiceInfo(att, "mike16", "en-us", ATT16Priority),
		        new VoiceInfo(att, "mike8", "en-us", ATT8Priority),
		        new VoiceInfo(att, "claire16", "en-us", ATT16Priority),
		        new VoiceInfo(att, "claire8", "en-us", ATT8Priority),
		        new VoiceInfo(att, "crystal16", "en-us", ATT16Priority),
		        new VoiceInfo(att, "crystal8", "en-us", ATT8Priority),
		        new VoiceInfo(att, "julia16", "en-us", ATT16Priority),
		        new VoiceInfo(att, "julia8", "en-us", ATT8Priority),
		        new VoiceInfo(att, "lauren16", "en-us", ATT16Priority),
		        new VoiceInfo(att, "lauren8", "en-us", ATT8Priority),
		        new VoiceInfo(att, "mel16", "en-us", ATT16Priority),
		        new VoiceInfo(att, "mel8", "en-us", ATT8Priority),
		        new VoiceInfo(att, "ray16", "en-us", ATT16Priority),
		        new VoiceInfo(att, "ray8", "en-us", ATT8Priority),
		        new VoiceInfo(att, "rich16", "en-us", ATT16Priority),
		        new VoiceInfo(att, "rich8", "en-us", ATT8Priority),
		        new VoiceInfo(att, "alberto16", "es-us", ATT16Priority),
		        new VoiceInfo(att, "alberto8", "es-us", ATT8Priority),
		        new VoiceInfo(att, "rosa16", "es-us", ATT16Priority),
		        new VoiceInfo(att, "rosa8", "es-us", ATT8Priority),
		        new VoiceInfo(att, "francesca16", "it", ATT16Priority),
		        new VoiceInfo(att, "francesca8", "it", ATT8Priority),
		        new VoiceInfo(att, "giovanni6", "it", ATT16Priority),
		        new VoiceInfo(att, "giovanni8", "it", ATT8Priority),
		        new VoiceInfo(att, "marina16", "pt-br", ATT16Priority),
		        new VoiceInfo(att, "marina8", "pt-br", ATT8Priority),
		        new VoiceInfo(att, "marina16", "pt-br", ATT16Priority),
		        new VoiceInfo(att, "marina8", "pt-br", ATT8Priority),
		        new VoiceInfo(att, "tiago16", "pt-br", ATT16Priority),
		        new VoiceInfo(att, "tiago8", "pt-br", ATT8Priority),
		        //Microsoft:
		        new VoiceInfo(microsoft, "en-us", "Microsoft Anna", 4),
		        new VoiceInfo(microsoft, "en-us", "Microsoft David", 6),
		        new VoiceInfo(microsoft, "en-us", "Microsoft Zira", 6),
		        new VoiceInfo(microsoft, "en-uk", "Microsoft Hazel", 6),
		        new VoiceInfo(microsoft, "en-us", "Microsoft Mike", 2),
		        new VoiceInfo(microsoft, "zh", "Microsoft Lili", 3),
		        new VoiceInfo(microsoft, "Microsoft Simplified Chinese", "zh",
		                2)
		};
		Set<VoiceInfo> priorities = new HashSet<VoiceInfo>(Arrays.asList(info));

		//Override and add some priorities from the system properties.
		//format: priority.ven_dor.voice_name.language = priorityVal
		Properties props = System.getProperties();
		for (String key : props.stringPropertyNames()) {
			String[] parts = key.split("\\.");
			if (parts.length == 4 && "priority".equalsIgnoreCase(parts[0])) {
				float priority;
				try {
					priority = Float.valueOf(props.getProperty(key));
				} catch (NumberFormatException e) {
					continue; //priority ignored
				}
				//'_' are replaced with ' ', but sometimes '_' really means '_'
				//so we must deal with all the possibilities
				//Another way would be to move the pair {vendor, name} from the key
				//to the value.
				for (String lang : new String[]{
				        parts[3], getPrefix(parts[3])
				}) {
					if (!lang.equals(parts[3]))
						priority -= priorityVariantPenalty;

					for (String vendor : new String[]{
					        parts[1], parts[1].replace("_", " ")
					})
						for (String name : new String[]{
						        parts[2], parts[2].replace("_", " ")
						}) {
							VoiceInfo vi = new VoiceInfo(vendor, name, lang,
							        priority);
							if (!priorities.add(vi)) {
								priorities.remove(vi);
								priorities.add(vi);
							}
						}
				}

			}
		}

		//copy the priorities with language variants removed
		mVoicePriorities = new ArrayList<VoiceInfo>(priorities);
		for (VoiceInfo vinfo : priorities) {
			String shortLang = getPrefix(vinfo.language);
			if (!shortLang.equals(vinfo.language)) {
				mVoicePriorities.add(new VoiceInfo(vinfo.voice, shortLang,
				        vinfo.priority - priorityVariantPenalty));
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

	public TTSRegistry() {
		ttsServices = new HashMap<TTSService, Boolean>();
	}

	/**
	 * @return the list of all the voices that can be automatically chosen by
	 *         the pipeline. It can help TTS adapters to build their list of
	 *         available voices.
	 */
	public static Collection<VoiceInfo> getAllPossibleVoices() {
		return mVoicePriorities;
	}

	/**
	 * Initialize the TTS services. Combine voices and TTS-services to build
	 * maps that allow one to quickly access to the best voices or the best
	 * services.
	 */
	public void regenerateVoiceMapping() {
		List<TTSService> workingServices = new ArrayList<TTSService>();

		for (Map.Entry<TTSService, Boolean> tts : ttsServices.entrySet()) {
			String fullname = tts.getKey().getName() + "-"
			        + tts.getKey().getVersion();
			if (tts.getValue()) {
				workingServices.add(tts.getKey());
				mLogger.info(fullname + " already initialized");
			} else {
				try {
					tts.getKey().initialize();
					workingServices.add(tts.getKey());
					tts.setValue(true);
					mLogger.info(fullname + " successfully initialized");
				} catch (Throwable t) {
					StringWriter writer = new StringWriter();
					PrintWriter printWriter = new PrintWriter(writer);
					t.printStackTrace(printWriter);
					printWriter.flush();
					mLogger.info(fullname + " could not be initialized");
					mLogger.debug(fullname + " init error: "
					        + writer.toString());
				}
			}
		}
		mLogger.info("number of working TTS services: "
		        + workingServices.size() + "/" + ttsServices.size());

		mBestServices = new HashMap<Voice, TTSService>();
		for (TTSService tts : workingServices)
			try {

				Collection<Voice> voices = tts.getAvailableVoices();
				if (voices != null)
					for (Voice v : voices) {
						TTSService competitor = mBestServices.get(v);
						if (competitor == null
						        || competitor.getOverallPriority() < tts
						                .getOverallPriority()) {
							mBestServices.put(v, tts);

						}
					}
			} catch (SynthesisException e) {
				//voices of this TTS Service are ignored
			}

		mBestVoices = new HashMap<String, Voice>();
		for (VoiceInfo voiceInfo : mVoicePriorities) {

			if (!mBestVoices.containsKey(voiceInfo.language)
			        && mBestServices.containsKey(voiceInfo.voice)) {
				mBestVoices.put(voiceInfo.language, voiceInfo.voice);
			}
		}

		mVendors = new HashMap<String, TTSService>();
		for (TTSService tts : workingServices) {
			TTSService competitor = mVendors.get(tts.getName());
			if (competitor == null
			        || competitor.getOverallPriority() < tts
			                .getOverallPriority())
				mVendors.put(tts.getName(), tts);
		}

	}

	public Voice findAvailableVoice(Voice preferredVoice, String lang) {
		if (mBestServices.containsKey(preferredVoice))
			return preferredVoice;
		return mBestVoices.get(lang);
	}

	/**
	 * @param voice is an available voice (but voice.name can be empty)
	 * @return the best TTS Service for @param voice
	 */
	public TTSService getTTS(Voice voice) {
		if (voice.name.isEmpty())
			return mVendors.get(voice.vendor);
		return mBestServices.get(voice);
	}

	public void addTTS(TTSService tts) {
		ttsServices.put(tts, false);
	}

	public void removeTTS(TTSService tts) {
		ttsServices.remove(tts);
	}

}
