package de.hshsoft.cordova_starter;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

import android.content.Context;
import android.location.Address;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationManager;
import android.text.TextUtils;
import android.util.Log;

/**
 * 
 * @author daniele <br>
 *         Helper class LocationCoder:<br>
 *         Obtain current location GPS coordinates.<br>
 *         Obtain addresses by GPS coordinates. <br>
 *         Obtain accurate address parts.<br>
 */
public class LocationCoder {
	private static String TAG = TAGS.TAG_LocationCoder;

	/**
	 * Retrieve a {@link List} of {@link Address Addresses} from GPS coordinates
	 * 
	 * @param context
	 *            Application context
	 * @param locale
	 *            Locale
	 * @param lat
	 *            Latitude
	 * @param lng
	 *            Longitude
	 * @param len
	 *            Length of the max length of the returned list.<br>
	 *            A value from {@code 1} to {@code 5} is recommended
	 * @return List&lt;Address&gt; Max 5 addresses
	 * @throws IOException
	 *             Can be caused by missing Internet connection
	 */
	public static List<Address> getLocationAddressList(final Context context,
			final Locale locale, final float lat, final float lng, final int len)
			throws IOException {
		Geocoder geocoder = new Geocoder(context, locale);
		List<Address> addresses = geocoder.getFromLocation(lat, lng, len);
		return addresses;
	}

	/**
	 * Retrieve the first matching Address of given GPS coordinates
	 * 
	 * @param context
	 *            Application context<br>
	 *            May not be {@code null}
	 * @param locale
	 *            Locale<br>
	 *            May be {@code null}, when {@code null} then
	 *            {@link Locale#getDefault()} is internally used by
	 *            {@link Geocoder}
	 * @param lat
	 *            Latitude
	 * @param lng
	 *            Longitude
	 * @return Address The Address represented by the give GPS coordinates
	 * @throws IOException
	 *             Can be caused by missing Internet connection
	 */
	public static Address getLocationAddress(final Context context,
			final Locale locale, final float lat, final float lng)
			throws IOException {
		Address address = null;
		List<Address> addresses = getLocationAddressList(context, locale, lat,
				lng, 1);
		if (null != addresses && !addresses.isEmpty()) {
			address = addresses.get(0);
		}
		return address;
	}

	/**
	 * 
	 * @param context
	 *            Application context<br>
	 *            May not be {@code null}
	 * @param locale
	 *            Locale<br>
	 *            May be {@code null}, when {@code null} then
	 *            {@link Locale#getDefault()} is internally used by
	 *            {@link Geocoder}
	 * @return
	 */
	public static Address getCurrentLocation(final Context context,
			final Locale locale) {
		Address _address = null;
		final Geocoder d = null != locale ? new Geocoder(context, locale)
				: new Geocoder(context);
		try {
			final Location loc = getCurrentLocation(context);
			final double latitude = loc.getLatitude();
			final double longitude = loc.getLongitude();
			final List<Address> list = d
					.getFromLocation(latitude, longitude, 1);
			if (null != list) {
				for (final Address address : list) {
					_address = address;
					break;
				}
			}
		} catch (final Exception e) {
			if (Log.isLoggable(TAG, Log.ERROR)) {
				Log.e(TAG, TAG, e);
			}
		}
		return _address;
	}

	/**
	 * Retrieve the current location GPS coordinates
	 * 
	 * @param context
	 *            Application context<br>
	 *            May not be {@code null}
	 * @return Location<br>
	 *         May be {@code null}
	 */
	public static Location getCurrentLocation(final Context context) {
		Location location = null;
		try {
			final LocationManager lm = (LocationManager) context
					.getSystemService(Context.LOCATION_SERVICE);
			final Criteria criteria = new Criteria();
			criteria.setAccuracy(Criteria.ACCURACY_FINE);
			criteria.setAltitudeRequired(false);
			criteria.setBearingRequired(false);
			criteria.setCostAllowed(true);
			final String strLocationProvider = lm.getBestProvider(criteria,
					true);
			final Location l_location = lm
					.getLastKnownLocation(strLocationProvider);
			if (l_location != null) {
				location = l_location;
			}
		} catch (final Exception e) {
			if (Log.isLoggable(TAG, Log.ERROR)) {
				Log.e(TAG, TAG, e);
			}
		}
		return location;
	}

	/**
	 * AddressPart, it is used to obtain address details more accurate
	 * 
	 * @author daniele
	 * 
	 */
	public static enum AddressPart {
		COUNTRY, STATE, POSTALCODE, CITY, DESTRICT, STREET, HOUSENUMBER,
	}

	/**
	 * Get Part from {@link Address}
	 * 
	 * @param address
	 *            Address <br>
	 *            May not be {@code null}, otherwise {@code null} will be
	 *            returned
	 * @param addressPart
	 *            AddressPart<br>
	 *            May not be {@code null}, otherwise {@code null} will be
	 *            returned
	 * @return String, the requested part of the given address or {@code null}
	 */
	public static String getFromAddress(final Address address,
			final AddressPart addressPart) {
		String part = null;
		if (null != address)
			if (null != addressPart)
				switch (addressPart) {
				case COUNTRY:
					part = address.getCountryName();
					break;
				case STATE:
					part = address.getAdminArea();
					break;
				case POSTALCODE:
					part = address.getPostalCode();
					break;
				case CITY:
					part = address.getLocality();
					break;
				case DESTRICT:
					part = address.getSubLocality();
					break;
				case STREET:
					part = address.getThoroughfare();
					if (TextUtils.isEmpty(part))
						part = address.getFeatureName();
					break;
				case HOUSENUMBER:
					part = address.getSubThoroughfare();
					break;
				}
		return part;
	}
}
