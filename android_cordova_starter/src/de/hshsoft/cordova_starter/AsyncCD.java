package de.hshsoft.cordova_starter;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.net.ssl.HttpsURLConnection;

import org.apache.cordova.api.LOG;
import org.apache.cordova.api.Plugin;
import org.apache.cordova.api.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

/**
 * daniele.pecora <br>
 * Cordova Plugin for asynchronous requests
 * 
 * 
 * */
public class AsyncCD extends Plugin {
	private static final String TAG = TAGS.TAG_AsyncCD;
	private static final String ACTION_GET_JSON = "getJSON";
	private static final String PARAM_URL = "url";

	/**
	 * Executes the request and returns PluginResult.
	 * 
	 * @param action
	 *            The action to execute.
	 * @param args
	 *            JSONArry of arguments for the plugin.
	 * @param callbackId
	 *            The callback id used when calling back into JavaScript.
	 * @return A PluginResult object with a status and message.
	 */
	public PluginResult execute(String action, JSONArray args, String callbackId) {
		PluginResult res = new PluginResult(PluginResult.Status.INVALID_ACTION);
		try {
			if (ACTION_GET_JSON.equals(action)) {
				JSONObject j1 = args.getJSONObject(0);
				String url = j1.has(PARAM_URL) ? j1.getString(PARAM_URL) : "";
				if (url != null && url.length() > 0) {
					AsyncCDResponse response = getWebRequest(url);
					if (Log.isLoggable(TAG, Log.DEBUG)) {
						Log.d(TAG, "Location: " + response.location);
						Log.d(TAG, "Message : " + response.responseMessage);
						Log.d(TAG, "Status  : " + response.status);
					}
					String content = response.content;
					if (null != content) {
						/**
						 * content has to be converted to JSON object, otherwise AsyncCD Plugin can not be generalized.<br>
						 * that is why on wp7 cordova return always a JSON object.<br>
						 */
						res = new PluginResult(PluginResult.Status.OK, new JSONObject(content));
					} else {
						res = new PluginResult(PluginResult.Status.NO_RESULT);
					}
				} else {
					res = new PluginResult(PluginResult.Status.ERROR);
				}
			} else {
				res = new PluginResult(PluginResult.Status.INVALID_ACTION);
			}
		} catch (JSONException e) {
			res = new PluginResult(PluginResult.Status.JSON_EXCEPTION,
					e.getLocalizedMessage());
		}
		return res;
	}

	private static class AsyncCDResponse {
		String content;
		int status;
		String location;
		String responseMessage;
	}

	/**
	 * no need for Asynchronous task.<br>
	 * Cordova manages to call this Method in separate Process.
	 * 
	 * @param url
	 * @return
	 */
	private static AsyncCDResponse getWebRequest(String url) {
		AsyncCDResponse res = null;
		try {
			res = new AsyncCDResponse();
			System.setProperty("java.net.useSystemProxies", "true");
			URL neturl = new URL(url);
			URLConnection conn = neturl.openConnection();
			res.location = conn.getHeaderField("Location");
			if (conn instanceof HttpsURLConnection) {
				HttpsURLConnection c = (HttpsURLConnection) conn;
				res.responseMessage = c.getResponseMessage();
			} else if (conn instanceof HttpURLConnection) {
				HttpURLConnection c = (HttpURLConnection) conn;
				res.responseMessage = c.getResponseMessage();
			}
			InputStream is = conn.getInputStream();
			String contentType = conn.getContentType();
			int len = conn.getContentLength();
			if (-1 == len) {
				if (Log.isLoggable(TAG, Log.DEBUG)) {
					Log.d(TAG,
							"sendstream [ Iterate all HEADER-FIELDS, searching for 'Content-Length'.]");
				}
				final Map<String, List<String>> header = conn.getHeaderFields();
				final Set<Map.Entry<String, List<String>>> set = header
						.entrySet();
				for (final Map.Entry<String, List<String>> entry : set) {
					final String key = entry.getKey();
					final List<String> value = entry.getValue();
					if (null != value) {
						// hier unbedingt equalsIgnoreCase da key auch null sein
						// kann!!!
						if ("content-lenght".equalsIgnoreCase(key)) {
							for (final String string : value) {
								try {
									len = Integer.valueOf(string);
								} catch (final Exception e) {
								}
								if (len > -1) {
									break;
								}
							}
							break;
						}
					}
				}
			}
			if (LOG.isLoggable(Log.DEBUG)) {
				Log.d(TAG, "Content-Length:" + len);
				Log.d(TAG, "Content-Type:" + contentType);
			}
			ByteArrayOutputStream out = new ByteArrayOutputStream();
			byte[] buf = new byte[1];
			while (true) {
				final int read = is.read(buf);
				if (read == -1) {
					break;
				}
				out.write(buf);
			}
			is.close();
			out.close();
			res.content = out.toString();
		} catch (Exception e) {
			if (Log.isLoggable(TAG, Log.ERROR)) {
				Log.e(TAG, "URL:" + url, e);
			}
		} finally {

		}
		return res;
	}
}
