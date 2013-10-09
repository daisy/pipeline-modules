#include "org_daisy_pipeline_tts_attnative_ATTLib.h"

#include <TTSApi.h>
#include <TTSUnixAPI.h>
#include <iostream>
#include <cstdlib>

struct ErrorHandler:  public CTTSErrorInfoObject{
  TTS_RESULT onErrorMessage(TTS_RESULT error, const char *pszErrorMessage){
    return TTS_OK;
  }
  TTS_RESULT onWarningMessage(const char *pszInformationMessage){
    return TTS_OK;
  }
  TTS_RESULT onTraceMessage(int nTraceLevel, const char *pszTraceMessage){
    return TTS_OK;
  }
};

struct CSDKSink : public CTTSSink{
  jobject	handler;
  JNIEnv*	env;
  jclass	klass;
  jmethodID	onRecvAudioID;
  long		audioLength;
  const void*	pAudioData;

  TTS_RESULT onNotification(CTTSNotification *pNotification) {
    switch (pNotification->Notification()) {
    case TTSNOTIFY_BOOKMARK:
      {
	utf8string utf8bookmark;
	if (pNotification->Bookmark(utf8bookmark) == TTS_OK) {
	  jstring name = env->NewStringUTF((const char*) utf8bookmark.c_str());
	  jmethodID mid = env->GetStaticMethodID(klass, "onRecvMark", "(Ljava/lang/Object;Ljava/lang/String;)V");
	  env->CallStaticVoidMethod(klass, mid, handler, name);
	}
      }
      break;
    case TTSNOTIFY_AUDIO:
      audioLength = 0;
      if (pNotification->AudioData(&pAudioData, &audioLength) == TTS_OK && (audioLength > 0)){
	jobject directBuffer = env->NewDirectByteBuffer((void*) pAudioData, audioLength);
	env->CallStaticLongMethod(klass, onRecvAudioID, handler, directBuffer, audioLength);
      }
      break;
    default:
      break;
    }

    return TTS_OK;
  }
};


#define MAX_SENTENCE_SIZE (1024*256)

struct Connection{
  ErrorHandler  errHandler; //TODO: make sure the destructor do the same as ErrorHandler::Release()
  CSDKSink*     sink;
  CTTSEngine*   engine;
  char		sentence[MAX_SENTENCE_SIZE];
};

namespace{
  void release(Connection* conn){
    if (conn->engine != 0){
      conn->engine->Shutdown();
      conn->engine = 0;
    }
    //there likely to be a memory leak here
    //but calling conn->engine->Release() or conn->sink->Release() is too risky

    delete conn->sink;
    delete conn;
  }

  PCUTF8String toUTF8(JNIEnv* env, jstring text, char* buff, int maxSize){
    static char empty[] = {'\0'};
    //warning: Java and JNI use a modified version of UTF8 while ATT uses another one
    //or the true one (if so, why building utf8strings from null terminated char arrays?)
    //Perhaps it won't work with utf8string including null characters.
    int nativeSize = env->GetStringLength(text);
    if (nativeSize >= maxSize){
      return (PCUTF8String) empty;
    }

    env->GetStringUTFRegion(text, 0, env->GetStringLength(text), buff);
    buff[nativeSize] = '\0';
    return (PCUTF8String) buff;
  }
}

JNIEXPORT jlong JNICALL
Java_org_daisy_pipeline_tts_attnative_ATTLib_openConnection
(JNIEnv *env, jclass klass, jstring host, jint port, jint sampleRate, jint bitsPerSample){

  Connection* conn = new Connection();

  conn->sink = new CSDKSink();
  conn->sink->AddRef();

  struct TTSConfig cfgSync(TTSENGINEMODEL_CLIENTSERVER_CURRENT,
			   TTSENGINE_SYNCHRONOUS, &conn->errHandler);

  char nativeHost[256];
  TTSServerConfig serverCfg(toUTF8(env, host, nativeHost, 256), port);
  cfgSync.m_lstServerConfig.push_back(serverCfg);

  TTS_RESULT r = ttsCreateEngine(&conn->engine, cfgSync);
  if (r != TTS_OK){
    //TODO:Error
    conn->engine = 0;
  }
  else
    conn->engine->AddRef();

  if (r == TTS_OK && (r = conn->engine->SetSink(conn->sink)) != TTS_OK) {
    //TODO:Error
  }
  if (r == TTS_OK && (r = conn->engine->Initialize()) != TTS_OK) {
    //TODO:Error
  }

  TTSAudioFormat format, formatReturned;
  format.m_nType = TTSAUDIOTYPE_DEFAULT;
  format.m_nSampleRate = sampleRate;
  format.m_nBits = bitsPerSample;
  if (r == TTS_OK && (r == conn->engine->SetAudioFormat(&format, &formatReturned)) != TTS_OK){
    //TODO:Error
  }

  long notifevents = TTSNOTIFY_AUDIO|TTSNOTIFY_BOOKMARK;
  if (r == TTS_OK && (r = conn->engine->SetNotifications(notifevents, notifevents)) != TTS_OK) {
    //TODO:Error
  }

  if (r != TTS_OK){
    release(conn);
    return 0;
  }

  return reinterpret_cast<long>(conn);
}


JNIEXPORT jint JNICALL
Java_org_daisy_pipeline_tts_attnative_ATTLib_closeConnection
(JNIEnv *, jclass, jlong connection){
  release(reinterpret_cast<Connection*>(connection));
  return 0;
}


JNIEXPORT jint JNICALL
Java_org_daisy_pipeline_tts_attnative_ATTLib_synthesizeRequest
(JNIEnv* env, jclass klass, jobject handler, jlong connection, jstring text){
  Connection* conn = reinterpret_cast<Connection*>(connection);

  conn->sink->env = env;
  conn->sink->klass = klass;
  conn->sink->onRecvAudioID =
    env->GetStaticMethodID(klass, "onRecvAudio", "(Ljava/lang/Object;Ljava/lang/Object;I)V");
  conn->sink->handler = handler;

  int utf8size = std::min(MAX_SENTENCE_SIZE/2, env->GetStringLength(text));
  int nativeSize = env->GetStringLength(text);
  env->GetStringUTFRegion(text, 0, utf8size, conn->sentence);
  conn->sentence[nativeSize] = '\0';

  //the cast here is necessary to make it interpret it as utf8 rather than latin-1
  TTS_RESULT r =
    conn->engine->Speak(toUTF8(env, text, conn->sentence, MAX_SENTENCE_SIZE), CTTSEngine::sf_ssml);

  if (r != TTS_OK){
    return 1;
  }

  return 0;
}
