package org.daisy.pipeline.file;

import java.io.File;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.net.URI;
import java.net.URISyntaxException;

import org.daisy.common.file.URLs;

/**
 * A collection of file/document/URI related utility functions.
 */
public final class FileUtils {

	private FileUtils() {}

	/**
	 * Create a <a href="https://www.w3.org/TR/xproc/#cv.result"><code>c:result</code></a> document
	 *
	 * @param text the value of the text node that the c:result element should contain
	 * @return the document as a Reader object
	 */
	public static Reader cResultDocument(String text) {
		StringBuilder sb = new StringBuilder();
		sb.append("<c:result xmlns:c=\"http://www.w3.org/ns/xproc-step\">")
			.append(text)
			.append("</c:result>");
		return new StringReader(sb.toString());
	}

	/* ============= */
	/* URI functions */
	/* ============= */

	public static URI normalizeURI(URI uri) {
		try {
			if ("jar".equals(uri.getScheme()))
				return URLs.asURI("jar:" + normalizeURI(URLs.asURI(uri.toASCIIString().substring(4))).toASCIIString());
			uri = uri.normalize();
			String scheme = uri.getScheme();
			String authority = uri.getAuthority();
			if (scheme != null) scheme = scheme.toLowerCase();
			if (authority != null) authority = authority.toLowerCase();
			uri = new URI(scheme, authority, uri.getPath(), uri.getQuery(), uri.getFragment());
			uri = expand83(uri);
			return uri;
		} catch (URISyntaxException e) {
			throw new RuntimeException(e);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	/**
	 * Expand 8.3 encoded path segments.
	 *
	 * For instance `C:\DOCUME~1\file.xml` will become `C:\Documents and
	 * Settings\file.xml`
	 */
	public static String expand83(String uri) throws URISyntaxException, IOException {
		if (uri == null || !uri.startsWith("file:/")) {
			return uri;
		}
		return expand83(URLs.asURI(uri)).toASCIIString();
	}

	private static URI expand83(URI uri) throws URISyntaxException, IOException {
		if (uri == null || !"file".equals(uri.getScheme())) {
			return uri;
		}
		String protocol = "file";
		String path = uri.getPath();
		String zipPath = null;
		if (path.contains("!/")) {
			// it is a path to a ZIP entry
			zipPath = path.substring(path.indexOf("!/")+1);
			path = path.substring(0, path.indexOf("!/"));
		}
		String query = uri.getQuery();
		String fragment = uri.getFragment();
		File file = new File(new URI(protocol, null, path, null, null));
		URI expandedUri = expand83(file, path.endsWith("/"));
		if (expandedUri == null) {
			return uri;
		} else {
			path = expandedUri.getPath();
			if (zipPath != null)
				path = path + "!" + new URI(null, null, zipPath, null, null).getPath();
			return new URI(protocol, null, path, query, fragment);
		}
	}

	public static URI expand83(File file) throws URISyntaxException, IOException {
		return expand83(file, false);
	}

	private static URI expand83(File file, boolean isDir) throws URISyntaxException, IOException {
		if (file.exists()) {
			return URLs.asURI(file.getCanonicalFile());
		} else {
			// if the file does not exist a parent directory may exist which can be canonicalized
			String relPath = file.getName();
			if (isDir)
				relPath += "/";
			File dir = file.getParentFile();
			while (dir != null) {
				if (dir.exists())
					return URLs.resolve(URLs.asURI(dir.getCanonicalFile()), new URI(null, null, relPath, null, null));
				relPath = dir.getName() + "/" + relPath;
				dir = dir.getParentFile();
			}
			return URLs.asURI(file);
		}
	}
>>>>>>> 4952ccbdbf (Implement px:normalize-uri in Java)
}
