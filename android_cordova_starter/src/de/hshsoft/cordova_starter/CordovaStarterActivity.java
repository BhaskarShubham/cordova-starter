package de.hshsoft.cordova_starter;

import java.util.HashMap;

import org.apache.cordova.CordovaChromeClient;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaWebViewClient;
import org.apache.cordova.DroidGap;

import android.app.Dialog;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.v4.view.MenuItemCompat;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.webkit.GeolocationPermissions.Callback;
import android.webkit.WebSettings;
import android.webkit.WebSettings.RenderPriority;
import android.webkit.WebView;

/**
 * 
 * @author daniele <br>
 *         All this code doesn't really depends on Cordova and can be also used
 *         in a regular {@link WebView}
 */
public class CordovaStarterActivity extends DroidGap {
	private String startpage_url = null;
	private CustomViewClient testViewClient;
	private CustomChromeClient testChromeClient;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		testViewClient = new CustomViewClient(this);
		testChromeClient = new CustomChromeClient(this);
		super.init(new CordovaWebView(this), testViewClient, testChromeClient);

		// this settings may speed things up... but must not. have to try this
		super.appView.getSettings().setRenderPriority(RenderPriority.HIGH);
		super.appView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);

		startpage_url = getString(R.string.startpage_url);
		super.loadUrl(startpage_url);
	}

	public class CustomChromeClient extends CordovaChromeClient {
		public CustomChromeClient(DroidGap arg0) {
			super(arg0);
			Log.d("userwebview", "CustomChromeClient()");
		}

		@Override
		public void onGeolocationPermissionsShowPrompt(String origin,
				Callback callback) {
			Log.d("userwebview", "onGeolocationPermissionsShowPrompt(" + origin
					+ ")");
			super.onGeolocationPermissionsShowPrompt(origin, callback);
			callback.invoke(origin, true, false);
		}
	}

	private boolean pageIsLoading = false;

	/**
	 * This class can be used to override the GapViewClient and receive
	 * notification of {@link WebView} events.
	 */
	public class CustomViewClient extends CordovaWebViewClient {
		public CustomViewClient(DroidGap arg0) {
			super(arg0);
			Log.d("userwebview", "CustomViewClient()");
		}

		@Override
		public void onPageFinished(WebView arg0, String arg1) {
			super.onPageFinished(arg0, arg1);
			pageIsLoading = false;
			updateMenu();
		}

		@Override
		public void onPageStarted(WebView view, String url, Bitmap favicon) {
			super.onPageStarted(view, url, favicon);
			pageIsLoading = true;
			updateMenu();
		}

		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			Log.d("userwebview", "shouldOverrideUrlLoading(" + url + ")");
			return super.shouldOverrideUrlLoading(view, url);
		}

		@Override
		public void onReceivedError(WebView view, int errorCode,
				String description, String failingUrl) {
			Log.d("userwebview", "onReceivedError: Error code=" + errorCode
					+ " Description=" + description + " URL=" + failingUrl);
			super.onReceivedError(view, errorCode, description, failingUrl);
		}
	}

	@Override
	protected Dialog onCreateDialog(int id) {
		return super.onCreateDialog(id);
	}

	@Override
	public boolean onOptionsItemSelected(final MenuItem item) {
		boolean ret = false;
		if (null != item) {
			final int menuItemId = item.getItemId();
			if (1 == menuItemId) {
				super.loadUrl(startpage_url);
			} else if (2 == menuItemId) {
				super.loadUrl("javascript:window.location.reload(true)");
			} else if (3 == menuItemId) {
				super.loadUrl("javascript:document.execCommand('Stop');");
			} else if (4 == menuItemId) {
				String url = getString(R.string.menu_url);
				super.showWebPage(url, false, true,
						new HashMap<String, Object>());
			} else if (5 == menuItemId) {
				System.exit(0);
			}
		}
		return ret;
	}

	@Override
	public void onOptionsMenuClosed(Menu menu) {
		// TODO here we should give free blocked content
		super.onOptionsMenuClosed(menu);
	}

	@Override
	public void openOptionsMenu() {
		// TODO maybe we should here block the content view by an overlay,
		// it is not allowed to touch content when menu is opened
		super.openOptionsMenu();
	}

	private Menu menu;

	private void updateMenu() {
		if (null != menu) {
			int removeId = 2;
			int addId = 3;
			if (!pageIsLoading) {
				removeId = 3;
				addId = 2;
			}
			menu.removeItem(removeId);

			String[] menuItems = getResources()
					.getStringArray(R.array.app_menu);
			for (int j = 0; j < menuItems.length; j++) {
				int l_menu_item_counter = j + 1;
				if (l_menu_item_counter == addId) {
					MenuItem i = menu.findItem(l_menu_item_counter);
					if (null == i) {
						menu.add(1, l_menu_item_counter, l_menu_item_counter,
								menuItems[j]);
						final MenuItem item = menu
								.findItem(l_menu_item_counter);
						if (null != item) {
							MenuItemCompat
									.setShowAsAction(
											item,
											MenuItemCompat.SHOW_AS_ACTION_IF_ROOM
													| MenuItemCompat.SHOW_AS_ACTION_WITH_TEXT);
						}
					}
				}
			}
		}
	}

	@Override
	public boolean onMenuOpened(int featureId, Menu menu) {
		boolean ret = super.onMenuOpened(featureId, menu);
		updateMenu();
		return ret;
	}

	@Override
	public boolean onCreateOptionsMenu(final Menu menu) {
		this.menu = menu;
		String[] menuItems = getResources().getStringArray(R.array.app_menu);

		for (int j = 0; j < menuItems.length; j++) {
			int l_menu_item_counter = j + 1;
			if (l_menu_item_counter == 3 || l_menu_item_counter == 2)
				continue;
			menu.add(1, l_menu_item_counter, l_menu_item_counter, menuItems[j]);
			final MenuItem item = menu.findItem(l_menu_item_counter);
			if (null != item) {
				MenuItemCompat.setShowAsAction(item,
						MenuItemCompat.SHOW_AS_ACTION_IF_ROOM
								| MenuItemCompat.SHOW_AS_ACTION_WITH_TEXT);
			}
		}
		return super.onCreateOptionsMenu(menu);
	}
}