package org.daisy.pipeline.tts;

import java.io.File;

public class BinaryFinder {
	public static String find(String propertyName, String executableName) {
		String result = System.getProperty(propertyName);
		if (result != null)
			return result;

		String systemPath = System.getenv("PATH");
		String[] pathDirs = systemPath.split(File.pathSeparator);

		File fullyQualifiedExecutable = null;
		for (String pathDir : pathDirs) {
			File file = new File(pathDir, executableName);
			if (file.isFile()) {
				fullyQualifiedExecutable = file;
				return file.getAbsolutePath();
			}
		}
		return null;
	}
}
