package org.daisy.pipeline.tts;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.daisy.pipeline.tts.TTSService.Voice;

import com.google.common.collect.LinkedHashMultimap;
import com.google.common.collect.Multimap;

public class TTSRegistry {

	private Multimap<Voice, TTSService> ttsServices = LinkedHashMultimap
	        .<Voice, TTSService> create();

	private static class VoiceInfo {
		VoiceInfo(int priority, String language) {
			this.priority = priority;
			this.language = language;
		}

		int priority;
		String language;
	}

	private static String getPrefix(String language) {
		return language.split("[-_.]")[0];
	}

	private static final Map<Voice, VoiceInfo> mPriorityMap;
	private static final Map<String, List<Voice>> mLangToVoices;
	static {
		mPriorityMap = new HashMap<Voice, VoiceInfo>();
		for (String lang : new String[]{
		        "en", "fr", "es"
		}) {
			mPriorityMap.put(new Voice("espeak", lang), new VoiceInfo(1, lang));
		}

		//French
		mPriorityMap.put(new Voice("att", "alain16"), new VoiceInfo(5, "fr"));

		//English
		mPriorityMap.put(new Voice("att", "mike16"), new VoiceInfo(3, "en_us"));

		//override them with the system properties. format: priority.vendor.voicename.language = priorityVal
		//TODO: iterate over the properties

		//copy the priorities with language variants removed
		for (Map.Entry<Voice, VoiceInfo> e : mPriorityMap.entrySet()) {
			String shortLang = getPrefix(e.getValue().language);
			if (!shortLang.equals(e.getValue().language)) {
				mPriorityMap.put(e.getKey(), new VoiceInfo(
				        e.getValue().priority, shortLang));
			}
		}

		//create an access from language to voice, order by priority (descending order)
		mLangToVoices = new HashMap<String, List<Voice>>();
		for (Map.Entry<Voice, VoiceInfo> e : mPriorityMap.entrySet()) {
			String lang = e.getValue().language;
			List<Voice> li = mLangToVoices.get(lang);
			if (li == null) {
				li = new ArrayList<Voice>();
				mLangToVoices.put(lang, li);
			}
			li.add(e.getKey());
		}

		Comparator<Voice> comp = new Comparator<Voice>() {
			@Override
			public int compare(Voice v0, Voice v1) {
				return (mPriorityMap.get(v1).priority - mPriorityMap.get(v0).priority);
			}
		};

		for (List<Voice> li : mLangToVoices.values()) {
			Collections.sort(li, comp);
		}
	}

	private static List<Voice> EmptyList = new LinkedList<Voice>();

	public TTSService getTTS(Voice voice, String lang) {
		Collection<TTSService> candidates = ttsServices.get(voice);

		//find an alternative voice for the given language or its variant
		if (candidates == null || candidates.size() == 0) {
			List<Voice> alternateVoices1 = mLangToVoices.get(lang);
			if (alternateVoices1 == null) {
				alternateVoices1 = EmptyList;
			}
			List<Voice> alternateVoices2 = EmptyList;
			String shortLang = getPrefix(lang);
			if (!shortLang.equals(lang)) {
				alternateVoices2 = mLangToVoices.get(shortLang);
			}

			Iterator<Voice> it1 = alternateVoices1.iterator();
			Iterator<Voice> it2 = alternateVoices2.iterator();
			while ((candidates == null || candidates.size() == 0)
			        && (it1.hasNext() || it2.hasNext())) {
				if (it1.hasNext())
					candidates = ttsServices.get(it1.next());
				if ((candidates == null || candidates.size() == 0)
				        && it2.hasNext()) {
					candidates = ttsServices.get(it2.next());
				}
			}
		}

		if (candidates == null || candidates.size() == 0) {
			return null;
		}

		//find the best TTS service for the 
		TTSService best = null;
		int highestPriority = Integer.MIN_VALUE;
		for (TTSService s : candidates) {
			int p = s.getOverallPriority();
			if (p > highestPriority) {
				best = s;
				highestPriority = p;
			}
		}

		return best;
	}

	public void addTTS(TTSService tts) {
		try {
			for (Voice voice : tts.getAvailableVoices())
				ttsServices.put(voice, tts);
		} catch (Exception e) {
			//TTS is not added
		} catch (Error e) {
			//TTS is not added
		}
	}

	public void removeTTS(TTSService tts) {
		try {
			for (Voice voice : tts.getAvailableVoices())
				ttsServices.remove(voice, tts);
		} catch (Exception e) {
		} catch (Error e) {
		}
	}

}
