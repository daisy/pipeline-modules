package org.daisy.pipeline.tts.rest;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import org.json.JSONObject;

/**
 * REST Request to communicate with remote services (mainly tts services like google and amazon)
 * @author Nicolas Pavie @ braillenet.org
 *
 */
public class Request {
	
	
	private static List<String> httpMethods =  
			Arrays.asList(
				"GET","POST","PUT","DELETE","HEAD",
				"CONNECT","OPTIONS","TRACE","PATCH");
	
	private HashMap<String,String> headers = new HashMap<String,String>();
	private JSONObject parameters = null;
	private URL requestURL;
	private String method = "GET";
	private HttpURLConnection connection;
	
	/**
	 * Fully initialized request
	 * @param httpMethod possible values : "GET","POST","PUT","DELETE","HEAD", "CONNECT","OPTIONS","TRACE","PATCH"
	 * @param url a string of the complete request url (including url parameters like "?voice=smtg)"
	 * @param headers http headers of the request <br/>
	 * Use {@code null} to unset all headers.
	 * @param parameters json data parameters to send with the request (often associated with POST requests)<br/> 
	 * Use {@code null} for requests without parameters
	 * @throws Exception if the http method is not one of the list above
	 * @throws MalformedURLException if the url is not valid
	 */
	public Request(String httpMethod, String url, HashMap<String,String> headers, JSONObject parameters) throws Exception, MalformedURLException {
		this.setMethod(httpMethod);
		this.setRequestUrl(url);
		this.headers = headers;
		this.parameters = parameters;
	}
	
	
	
	public void addHeader(String name, String value) {
		this.headers.put(name, value);
	}
	
	
	public void setParameters(JSONObject parameters) {
		this.parameters = parameters;
	}
	
	/**
	 * Set the request url.
	 * If a previous connection was opened for the current request, close and destroy it. 
	 * @param requestUrl
	 */
	public void setRequestUrl(String url) throws MalformedURLException {
		this.requestURL = new URL(url);
		if(this.connection != null) {
			this.connection.disconnect();
			this.connection = null;
		}
	}
	
	/**
	 * Set the http method to use with the request
	 * @param httpMethod one of the following value : "GET","POST","PUT","DELETE","HEAD", "CONNECT","OPTIONS","TRACE","PATCH"
	 * @throws Exception if the http method value is not a valid one
	 */
	public void setMethod(String httpMethod) throws Exception{
		if( ! httpMethods.contains(httpMethod.toUpperCase())) {
			throw new Exception(httpMethod + " is not a valid HTTP method (valid methods : " + httpMethods.toString() + ")");
		} 
		this.method = httpMethod.toUpperCase();
	}
	
	
	/**
	 * Send the request to the requested url and retrieve the server answer as an input stream.
	 * @return the input stream, through which data are send back by the server
	 * @throws IOException if an error occured during the connection or while sending data to the server
	 */
	public InputStream send() throws IOException {
		
		connection = (HttpURLConnection) requestURL.openConnection();
		connection.setRequestMethod(method);
		if(headers != null) headers.forEach((String key, String value) -> {
				connection.setRequestProperty(key, value);
			});
		if(parameters != null) {
			connection.setDoOutput(true);
			try(OutputStream os = connection.getOutputStream()) {
				byte[] input = parameters.toString().getBytes("utf-8");
				os.write(input, 0, input.length);           
			}
		} else {
			connection.setDoOutput(false);
		}
		
		return connection.getInputStream();
	}
	
	/**
	 * Get the current connection object
	 * @return
	 */
	public HttpURLConnection getConnection() {
		return connection;
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
