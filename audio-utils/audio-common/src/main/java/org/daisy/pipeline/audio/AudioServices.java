package org.daisy.pipeline.audio;

import java.util.Collection;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

public class AudioServices {
  
 private final Collection<AudioEncoder> encoders = new CopyOnWriteArrayList<AudioEncoder>();
 
 public AudioEncoder getEncoder(Map<String,String> properties) {
   //TODO select the best encoder from the list
   return null;
 }
 
 public void addEncoder(AudioEncoder encoder) {
   encoders.add(encoder);
 }
 
 public void removeEncoder(AudioEncoder encoder) {
   encoders.remove(encoder);
 }
 
}