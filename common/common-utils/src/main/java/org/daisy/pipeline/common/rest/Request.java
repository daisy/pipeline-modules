package org.daisy.pipeline.common.rest;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Arrays;
import java.util.Map;
import java.util.HashMap;
import java.util.List;

/**
 * REST request to communicate with remote services (such as TTS services like Google and Amazon).
 *
 * @author Nicolas Pavie @ braillenet.org
 */
public class Request {

	private static List<String> httpMethods =
		Arrays.asList(
			"GET","POST","PUT","DELETE","HEAD",
			"CONNECT","OPTIONS","TRACE","PATCH");

	private Map<String,String> headers = new HashMap<String,String>();
	private String content = null;
	private URL requestURL;
	private String method = "GET";
	private HttpURLConnection connection;

	/**
	 * Fully initialized request
	 *
	 * @param httpMethod possible values: "GET", "POST", "PUT", "DELETE", "HEAD", "CONNECT", "OPTIONS", "TRACE", "PATCH"
	 * @param url a string of the complete request URL (including URL parameters like "?voice=smtg)"
	 * @param headers HTTP headers of the request
	 *                <p>Use {@code null} to unset all headers.</p>
	 * @param content content to send with the request (often associated with POST requests)
	 *                <p>Use {@code null} for requests without content</p>
	 * @throws Exception if the http method is not one of the list above
	 * @throws MalformedURLException if the url is not valid
	 */
	public Request(String httpMethod, String url, Map<String,String> headers, String content)
			throws IllegalArgumentException, MalformedURLException {
		this.setMethod(httpMethod);
		this.setRequestUrl(url);
		this.headers = headers;
		this.content = content;
	}

	public Request(String url) throws MalformedURLException {
		setRequestUrl(url);
	}

	public Request(URL url) {
		setRequestUrl(url);
	}

	/**
	 * Add a new header field with specified value to the request
	 *
	 * @param name name of the header field
	 * @param value value set for the field
	 */
	public Request addHeader(String name, String value) {
		headers.put(name, value);
		return this;
	}

	/**
	 * Set the request content, to be sent through the request connection output stream
	 *
	 * @param content content of the request
	 */
	public Request setContent(String content) {
		this.content = content;
		return this;
	}

	/**
	 * Set the request URL.
	 *
	 * <p>If a previous connection was opened for the current request, close and destroy it.</p>
	 */
	public Request setRequestUrl(String url) throws MalformedURLException {
		return setRequestUrl(new URL(url));
	}

	public Request setRequestUrl(URL url) {
		requestURL = url;
		if (this.connection != null) {
			this.connection.disconnect();
			this.connection = null;
		}
		return this;
	}

	/**
	 * Set the HTTP method to use with the request
	 *
	 * @param httpMethod one of the following values: "GET", "POST", "PUT", "DELETE", "HEAD", "CONNECT", "OPTIONS", "TRACE", "PATCH"
	 * @throws IllegalArgumentException if the HTTP method value is not a valid one
	 */
	public Request setMethod(String httpMethod) {
		if (!httpMethods.contains(httpMethod.toUpperCase())) {
			throw new IllegalArgumentException(httpMethod + " is not a valid HTTP method (valid methods : " + httpMethods.toString() + ")");
		}
		method = httpMethod.toUpperCase();
		return this;
	}

	/**
	 * Send the request to the requested URL and retrieve the server answer
	 *
	 * @return the {@link Response} object
	 * @throws InterruptedException if the current thread is interrupted while getting the response from the server
	 * @throws IOException if the response code could not be retrieved, or the body could not be read
	 */
	public Response send() throws InterruptedException, IOException {
		int status = 0;
		InputStream body = null;
		InputStream error = null;
		IOException ioe = null;
		try {
			connection = (HttpURLConnection)requestURL.openConnection();
			connection.setRequestMethod(method);
			if (headers != null)
				headers.forEach((String key, String value) -> {
						connection.setRequestProperty(key, value);
					});
			if (content != null) {
				connection.setDoOutput(true);
				try (OutputStream os = connection.getOutputStream()) {
					byte[] input = content.getBytes("utf-8");
					os.write(input, 0, input.length);
				}
			} else {
				connection.setDoOutput(false);
			}
			// handle thread interrupts (fired by TTSTimeout e.g.)
			Thread currentThread = Thread.currentThread();
			Thread handleInterrupt = new Thread() {
					public void run() {
						while (true) {
							try {
								sleep(1000);
							} catch (InterruptedException e) {
								return;
							}
							if (currentThread.isInterrupted()) {
								connection.disconnect(); // unblocks connection.getInputStream() below
								connection = null;
								return;
							}
						}
					}
				};
			handleInterrupt.start();
			try {
				body = connection.getInputStream();
			} catch (IOException e) {
				handleInterrupt.interrupt();
				if (connection == null)
					// cancelled by interrupt handler
					throw new InterruptedException("request was interrupted");
				else
					throw e;
			} finally {
				handleInterrupt.interrupt();
			}
		} catch (IOException e) {
			ioe = e;
		}
		try {
			status = getConnection().getResponseCode();
		} catch (IOException e) {
			throw new IOException(
				"Could not retrieve response code for request. Do you have an internet connection?", e);
		}
		if (ioe != null || status > 299)
			error = getConnection().getErrorStream();
		return new Response(status, body, error, ioe);
	}

	/**
	 * Get the current connection object
	 */
	public HttpURLConnection getConnection() {
		return connection;
	}

	/**
	 * Cancel the request, disconnecting it from the server
	 */
	public void cancel() {
		if (this.connection != null) {
			this.connection.disconnect();
			this.connection = null;
		}
	}
}
