package org.daisy.pipeline.tts.google.impl;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * Google Cloud Text-To-Speech REST Request class.
 * 
 * @author Louis Caille @ braillenet.org
 *
 */
public class GoogleRestRequest {
	
	/**
	 * Connection object to Google's server
	 */
	private HttpURLConnection connection = null;
	
	/**
	 * URL used to send the request
	 */
	private URL requestUrl;
	
	/**
	 * HTTP Method to use with the request.
	 * Default to GET.
	 * 
	 */
	private String method = "GET";
	
	/**
	 * JSON String of the request parameters.
	 * See <a href="https://cloud.google.com/text-to-speech/docs/how-to">google cloud text-to-speech API</a> for more informations.
	 * 
	 */
	private String requestParameters = null;
	
	
	/**
	 * Send the request to the requested url and retrieve the server answer as an input stream.
	 * @return the input stream, through which data are send back by the server
	 * @throws IOException if an error occured during the connection or while sending data to the server
	 */
	public InputStream send() throws IOException {

		connection = (HttpURLConnection) requestUrl.openConnection();
		connection.setRequestProperty("Accept", "application/json");
		connection.setRequestProperty("Content-Type", "application/json; utf-8");
		connection.setRequestMethod(method);

		if (requestParameters != null && requestParameters.length() > 2) {
			connection.setDoOutput(true);
			try(OutputStream os = connection.getOutputStream()) {
				byte[] input = requestParameters.getBytes("utf-8");
				os.write(input, 0, input.length);           
			}
		} else { 
			// not mandatory, but just in case of a change occured with the default impl
			connection.setDoOutput(false);
		}

		return connection.getInputStream();
	}

	/**
	 * return the current connection.
	 * @return the current connection of the request, or null if no connection has been opened or tried yet (current request was not send)
	 */
	public HttpURLConnection getConnection() {
		return connection;
	}

	/**
	 * @return the url used for the request
	 */
	public URL getRequestUrl() {
		return requestUrl;
	}

	/**
	 * Set the request url.
	 * If a previous connection was opened for the current request, close and destroy it. 
	 * @param requestUrl
	 */
	public void setRequestUrl(URL requestUrl) {
		this.requestUrl = requestUrl;
		if(this.connection != null) {
			this.connection.disconnect();
			this.connection = null;
		}
		
	}
	
	public void setMethod(String method) {
		this.method = method;
	}
	
	/**
	 * @return the current request parameters JSON string
	 */
	public String getRequestParameters() {
		return requestParameters;
	}

	/**
	 * Change the request parameters with a new JSON string.<br/>
	 *  See <a href="https://cloud.google.com/text-to-speech/docs/reference/rest">google cloud text-to-speech API</a> for more informations.
	 * @param requestParameters JSON string that holds new parameters. <br/> Example : "{\"input\":{\"ssml\":\"text to synthesise\"}, ... }"
	 */
	public void setRequestParameters(String requestParameters) {
		this.requestParameters = requestParameters;
	}
	
	/**
	 * Cancel the request, disconnecting it from the server
	 */
	public void cancel() {
		if(this.connection != null) {
			this.connection.disconnect();
			this.connection = null;
		}
	}


}
