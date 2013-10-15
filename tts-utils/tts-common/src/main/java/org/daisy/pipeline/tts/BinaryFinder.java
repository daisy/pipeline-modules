package org.daisy.pipeline.tts;

import java.io.File;

public class BinaryFinder {

	private static final String[] winExtensions = {
	        ".exe", ".bat", ".cmd", ".bin", ""
	};
	private static final String[] nixExtensions = {
	        "", ".run", ".bin", ".sh"
	};

	public static String find(String propertyName, String executableName) {
		String result = System.getProperty(propertyName);
		if (result != null)
			return result;

		String os = System.getProperty("os.name");
		String[] extensions;
		if (os != null && os.startsWith("Windows"))
			extensions = winExtensions;
		else
			extensions = nixExtensions;

		String systemPath = System.getenv("PATH");
		String[] pathDirs = systemPath.split(File.pathSeparator);
		for (String ext : extensions) {
			String fullname = executableName + ext;
			for (String pathDir : pathDirs) {
				File file = new File(pathDir, fullname);
				if (file.isFile()) {
					return file.getAbsolutePath();
				}
			}
		}
		return null;
	}
}
