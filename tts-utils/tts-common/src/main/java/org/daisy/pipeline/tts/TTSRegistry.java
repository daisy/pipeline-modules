package org.daisy.pipeline.tts;

import java.util.Collection;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

public class TTSRegistry {
  
 private final Collection<TTSService> ttsServices = new CopyOnWriteArrayList<TTSService >();
 
 public TTSService getTTS(Map<String,String> properties) {
   //TODO select the best service from the list
   return null;
 }
 
 public void addTTS(TTSService tts) {
   ttsServices.add(tts);
 }
 
 public void removeTTS(TTSService tts) {
   ttsServices.remove(tts);
 }
 
}