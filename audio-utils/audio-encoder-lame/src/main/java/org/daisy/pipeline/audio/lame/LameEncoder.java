package org.daisy.pipeline.audio.lame;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import org.daisy.pipeline.audio.AudioEncoder;

public class LameEncoder implements AudioEncoder {
    private static final String InputFormat = ".wav";
    private static final String OutputFormat = ".mp3";
    private String mLamePath;
    
    private static String findExecutableOnPath(String executableName){  
        String systemPath = System.getenv("PATH");  
        String[] pathDirs = systemPath.split(File.pathSeparator);  
   
        File fullyQualifiedExecutable = null;  
        for (String pathDir : pathDirs)  {  
            File file = new File(pathDir, executableName);  
            if (file.isFile()){  
                fullyQualifiedExecutable = file;  
                break;  
            }  
        }  
        return fullyQualifiedExecutable.getAbsolutePath();  
    }  
    

    //TODO: take the path from the properties if it exists
    //and raise an exception if nothing is found
    public LameEncoder() {
    	mLamePath = findExecutableOnPath("lame");
    }

    @Override
    public String encode(byte[] input, int size, AudioFormat audioFormat,
            Object caller, String name) {
        // generate the intermediate WAV file from the input audio data
        File intermediateFile;
        try {
            intermediateFile = File.createTempFile("chunk", InputFormat);
        } catch (IOException e1) {
            return null;
        }
        try {
            InputStream inputStream = new ByteArrayInputStream(input);
            AudioInputStream ais = new AudioInputStream(inputStream,
                    audioFormat, size / audioFormat.getFrameSize());

            AudioSystem.write(ais, AudioFileFormat.Type.WAVE, intermediateFile);
            ais.close();
            inputStream.close();
        } catch (FileNotFoundException e1) {
            intermediateFile.delete();
            return null;
        } catch (IOException e) {
            intermediateFile.delete();
            return null;
        }

        // execute the lame binary on the intermediate WAV file
        File encodedFile = null;
        String[] cmd = null;
        try {
            encodedFile = File.createTempFile("chunk", OutputFormat);
            cmd = new String[] {
                    mLamePath, "--silent",
                    intermediateFile.getAbsolutePath(),
                    encodedFile.getAbsolutePath()
            };
            Runtime.getRuntime().exec(cmd).waitFor();

        } catch (Exception e) {
            encodedFile = null;
            return null;
        } finally {
            intermediateFile.delete();
        }

        return encodedFile.toURI().toString();
    }
}
