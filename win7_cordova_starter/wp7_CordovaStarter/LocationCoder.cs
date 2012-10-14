using System;
using System.Device.Location;
using System.IO;
using System.Net;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text.RegularExpressions;

namespace wp7_CordovaStarter
{
    // Defines the status values for the geolocation service
    public enum GeoLocationPositionStatus
    {
        //Service is disabled
        Disabled = 0,
        //Service is ready and obtaining location data, hold on
        Ready = 1,
        //Service is initializing
        Initializing = 2,
        //Service is available but could not acquire any location data
        NoData = 3,
        //Service is available and has acquired location data
        LocationReceived= 4,
        //Application has no permission to use the location service
        NoPermission=5,
        //Error acquiring answer from reverselocation service
        ErrorReverseLocation=6,

    }
    // Bing Map API
    //
    //
    public class LocationCoder
    {
        public class PositionEventArgs : EventArgs
        {
            public PositionEventArgs(GeoLocationPositionStatus status)
            {
                this.latitude = Double.NaN;
                this.longitude = Double.NaN;
                this.location = null;
                this.status = status;
            }
            public PositionEventArgs(Double latitude, Double longitude, BingLocationResponse location, GeoLocationPositionStatus status)
            {
                this.latitude = latitude;
                this.longitude = longitude;
                this.location = location;
                this.status = status;
            }
            public Double latitude { get; private set; }
            public Double longitude { get; private set; }
            public BingLocationResponse location { get; private set; }
            public GeoLocationPositionStatus status { get; private set; }
        }

        private GeoCoordinateWatcher gcw;
        public Double latitude { get; private set; }
        public Double longitude { get; private set; }
        public BingLocationResponse location { get; private set; }
        public EventHandler<PositionEventArgs> onPositionChanged { get; set; }

        public LocationCoder()
        {
            this.gcw = new GeoCoordinateWatcher(GeoPositionAccuracy.High);
            this.gcw.StatusChanged += new EventHandler<GeoPositionStatusChangedEventArgs>(statusChanged);
            this.gcw.PositionChanged += new EventHandler<GeoPositionChangedEventArgs<GeoCoordinate>>(positionChanged);
        }

        public void start()
        {
            latitude = Double.NaN;
            longitude = Double.NaN;
            location = null;
            this.gcw.Start();
        }

        private void statusChanged(Object sender, GeoPositionStatusChangedEventArgs e)
        {
            switch (e.Status)
            {
                case GeoPositionStatus.Disabled:
                    // The Location Service is disabled or unsupported.
                    // Check to see whether the user has disabled the Location Service.
                    if (gcw.Permission == GeoPositionPermission.Denied)
                    {
                        // The user has disabled the Location Service on their device.
                        Console.Out.WriteLine("location is not functioning on this device");
                        if (null != onPositionChanged)
                            onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.NoPermission));
                    }
                    else
                    {
                        Console.Out.WriteLine("you have this application access to location.");
                        if (null != onPositionChanged)
                            onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.Disabled));
                    }
                    this.gcw.Stop();
                    break;
                case GeoPositionStatus.Initializing:
                    // The Location Service is initializing.
                    // Disable the Start Location button.
                    if (null != onPositionChanged)
                        onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.Initializing));
                    break;
                case GeoPositionStatus.NoData:
                    // The Location Service is working, but it cannot get location data.
                    // Alert the user and enable the Stop Location button.
                    Console.Out.WriteLine("location data is not available.");
                        if (null != onPositionChanged)
                            onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.NoData));
                    this.gcw.Stop();
                    break;

                case GeoPositionStatus.Ready:
                    // The Location Service is working and is receiving location data.
                    // Show the current position and enable the Stop Location button.
                    Console.Out.WriteLine("location data is available.");
                    if (null != onPositionChanged)
                        onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.Ready));
                    break;
            }
        }

        private void positionChanged(Object sender, GeoPositionChangedEventArgs<GeoCoordinate> e)
        {
            double latitude = e.Position.Location.Latitude;
            double longitude = e.Position.Location.Longitude;
            this.latitude = latitude;
            this.longitude = longitude;
            this.GetReverseLocation(this.latitude, this.longitude);
            this.gcw.Stop();
        }

        private void GetReverseLocation(double latitude, double longitude)
        {
            String apikey = "AuZVv-yn7M48aBHkBLfeXz2-1mtQMSujvfS0PmzZLnekc3JzbVejWtz5RPmTS0a_";
            String url = "https://dev.virtualearth.net/REST/v1/Locations/{0}?key={1}";
            String formattedLocation = string.Format("{0},{1}", latitude.ToString().Replace(",", "."), longitude.ToString().Replace(",", "."));
            String finalURL = string.Format(url, formattedLocation, apikey);
            Console.Write("GET " + url);
            HttpWebRequest httpWebRequest = (HttpWebRequest)HttpWebRequest.Create(url);
            httpWebRequest.Method = "GET";
            try
            {
                httpWebRequest.BeginGetResponse(GetReverseLocation_Response_Completed, httpWebRequest);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());

                if (null != onPositionChanged)
                    onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.ErrorReverseLocation));
                this.gcw.Stop();
            }
        }

        void GetReverseLocation_Response_Completed(IAsyncResult aResult)
        {
            try
            {
                //
                HttpWebRequest request = (HttpWebRequest)aResult.AsyncState;
                HttpWebResponse response = (HttpWebResponse)request.EndGetResponse(aResult);
                Stream resultStream = response.GetResponseStream();
                this.location = (BingLocationResponse)new DataContractJsonSerializer(typeof(BingLocationResponse)).ReadObject(resultStream);
                if (null != onPositionChanged)
                    onPositionChanged(this, new PositionEventArgs(this.latitude, this.longitude, this.location,GeoLocationPositionStatus.LocationReceived));
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                if (null != onPositionChanged)
                    onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.ErrorReverseLocation));
            }
            this.gcw.Stop();
            //OK
        }

        public enum AddressPart
        {
            COUNTRY, STATE, POSTALCODE, CITY, DESTRICT, STREET, HOUSENUMBER,
        }

        public static String getFromAddress(BingLocationResponse address, AddressPart addressPart)
        {
            String part = null;
                if (null != address)
                {
                    BingLocationResponse.ResourceSet.Resource.Address
                        a = address.resourceSets[0].resources[0].address;
                    String aline = a.addressLine;
                    switch (addressPart)
                    {
                        case AddressPart.COUNTRY:
                            part = a.countryRegion;
                            break;
                        case AddressPart.STATE:
                            part = a.adminDistrict2;
                            break;
                        case AddressPart.POSTALCODE:
                            part = a.postalCode;
                            break;
                        case AddressPart.CITY:
                            //liefert Prenzlauer Berg
                            part = a.locality;
                            break;
                        case AddressPart.DESTRICT:
                            //liefert Prenzlauer Berg
                            part = a.locality;
                            break;
                        case AddressPart.STREET:
                            if (null != aline)
                            {
                                Regex rx1 = new Regex("\b[0-9]* \b");
                                MatchCollection matches1 = rx1.Matches(aline);
                                String foundVal = null;
                                foreach (Match match in matches1)
                                {
                                    String number = match.Value.Trim();
                                    foundVal = aline.Replace(number, "");
                                    foundVal = foundVal.Trim();
                                    break;
                                }
                                if (null == foundVal)
                                {
                                    part = aline;
                                }
                                else
                                {
                                    part = foundVal;
                                }
                            }
                            break;
                        case AddressPart.HOUSENUMBER:
                            if (null != aline)
                            {
                                Regex rx2 = new Regex("\b[0-9]* \b");
                                MatchCollection matches2 = rx2.Matches(aline);
                                foreach (Match match in matches2)
                                {
                                    part = match.Value.Trim();
                                    break;
                                }
                            }
                            break;
                    }
                }
            return part;
        }


        [DataContract]
        public class BingLocationResponse
        {
            [DataMember]
            public string authenticationResultCode { get; set; }
            [DataMember]
            public string brandLogoUri { get; set; }
            [DataMember]
            public string copyright { get; set; }

            [DataMember]
            public ResourceSet[] resourceSets { get; set; }

            [DataMember]
            public string statusCode { get; set; }
            [DataMember]
            public string statusDescription { get; set; }
            [DataMember]
            public string traceId { get; set; }

            [DataContract]
            public class ResourceSet
            {
                [DataMember]
                public int estimatedTotal { get; set; }

                [DataMember]
                public Resource[] resources { get; set; }

                [DataContract(Namespace = "http://schemas.microsoft.com/search/local/ws/rest/v1", Name = "Location")]
                public class Resource
                {
                    [DataMember]
                    public string __type { get; set; }

                    [DataMember]
                    public double[] bbox { get; set; }

                    [DataMember]
                    public string name { get; set; }

                    [DataMember]
                    public Point point { get; set; }

                    [DataContract]
                    public class Point
                    {
                        [DataMember]
                        public string type { get; set; }

                        [DataMember]
                        public string[] coordinates { get; set; }
                    }

                    [DataMember]
                    public Address address { get; set; }

                    [DataContract]
                    public class Address
                    {
                        [DataMember]
                        public string addressLine { get; set; }
                        [DataMember]
                        public string adminDistrict { get; set; }
                        [DataMember]
                        public string adminDistrict2 { get; set; }
                        [DataMember]
                        public string countryRegion { get; set; }
                        [DataMember]
                        public string formattedAddress { get; set; }
                        [DataMember]
                        public string locality { get; set; }
                        [DataMember]
                        public string postalCode { get; set; }
                    }

                    [DataMember]
                    public string confidence { get; set; }

                    [DataMember]
                    public string entityType { get; set; }
                }
            }
        }
    }

    //Yahoo Place Finder
    //
    //
    public class YahooLocationCoder
    {
        public class PositionEventArgs : EventArgs
        {
            public PositionEventArgs(GeoLocationPositionStatus status)
            {
                this.latitude = Double.NaN;
                this.longitude = Double.NaN;
                this.location = null;
                this.status = status;
            }
            public PositionEventArgs(Double latitude, Double longitude, YahooLocationResponse location, GeoLocationPositionStatus status)
            {
                this.latitude = latitude;
                this.longitude = longitude;
                this.location = location;
                this.status = status;
            }
            public Double latitude { get; private set; }
            public Double longitude { get; private set; }
            public YahooLocationResponse location { get; private set; }
            public GeoLocationPositionStatus status { get; private set; }
        }

        private GeoCoordinateWatcher gcw;
        public Double latitude { get; private set; }
        public Double longitude { get; private set; }
        public YahooLocationResponse location { get; private set; }
        public EventHandler<PositionEventArgs> onPositionChanged { get; set; }
        
        public YahooLocationCoder()
        {
            this.gcw = new GeoCoordinateWatcher(GeoPositionAccuracy.High);
            this.gcw.StatusChanged += new EventHandler<GeoPositionStatusChangedEventArgs>(statusChanged);
            this.gcw.PositionChanged += new EventHandler<GeoPositionChangedEventArgs<GeoCoordinate>>(positionChanged);
        }

        public void start()
        {
            latitude = Double.NaN;
            longitude = Double.NaN;
            location = null;
            this.gcw.Start();
        }

        private void positionChanged(Object sender, GeoPositionChangedEventArgs<GeoCoordinate> e)
        {
            double latitude = e.Position.Location.Latitude;
            double longitude = e.Position.Location.Longitude;
            this.latitude = latitude;
            this.longitude = longitude;
            this.GetReverseLocation(this.latitude, this.longitude);
            this.gcw.Stop();
        }

        private void statusChanged(Object sender, GeoPositionStatusChangedEventArgs e)
        {
            switch (e.Status)
            {
                case GeoPositionStatus.Disabled:
                    // The Location Service is disabled or unsupported.
                    // Check to see whether the user has disabled the Location Service.
                    if (gcw.Permission == GeoPositionPermission.Denied)
                    {
                        // The user has disabled the Location Service on their device.
                        Console.Out.WriteLine("location is not functioning on this device");
                        if (null != onPositionChanged)
                            onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.NoPermission));
                    }
                    else
                    {
                        Console.Out.WriteLine("you have this application access to location.");
                        if (null != onPositionChanged)
                            onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.Disabled));
                    }
                    this.gcw.Stop();
                    break;
                case GeoPositionStatus.Initializing:
                    // The Location Service is initializing.
                    // Disable the Start Location button.
                    if (null != onPositionChanged)
                        onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.Initializing));
                    break;
                case GeoPositionStatus.NoData:
                    // The Location Service is working, but it cannot get location data.
                    // Alert the user and enable the Stop Location button.
                    Console.Out.WriteLine("location data is not available.");
                    if (null != onPositionChanged)
                        onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.NoData));
                    this.gcw.Stop();
                    break;

                case GeoPositionStatus.Ready:
                    // The Location Service is working and is receiving location data.
                    // Show the current position and enable the Stop Location button.
                    Console.Out.WriteLine("location data is available.");
                    if (null != onPositionChanged)
                        onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.Ready));
                    break;
            }
        }

        private void GetReverseLocation(double latitude, double longitude)
        {
            String appid = "UgZnHE6o";
            String url = "http://where.yahooapis.com/geocode?q={0}&gflags=R&flags=J&locale=de_DE&appid={1}";
            String formattedLocation = string.Format("{0},{1}", latitude.ToString().Replace(",", "."), longitude.ToString().Replace(",", "."));
            String finalURL = string.Format(url, formattedLocation, appid);
            Console.WriteLine("GET " + finalURL);
            HttpWebRequest httpWebRequest = (HttpWebRequest)HttpWebRequest.Create(finalURL);
            httpWebRequest.Method = "GET";
            try
            {
                httpWebRequest.BeginGetResponse(GetReverseLocation_Response_Completed, httpWebRequest);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());

                if (null != onPositionChanged)
                    onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.ErrorReverseLocation));
                this.gcw.Stop();
            }
        }

        void GetReverseLocation_Response_Completed(IAsyncResult aResult)
        {
            Console.WriteLine("URL Retrieved");
            try
            {
                //
                HttpWebRequest request = (HttpWebRequest)aResult.AsyncState;
                HttpWebResponse response = (HttpWebResponse)request.EndGetResponse(aResult);
                //debug only
                //String st = new StreamReader(response.GetResponseStream()).ReadToEnd();
                //Console.WriteLine(st);
                Stream resultStream = response.GetResponseStream();
                this.location = (YahooLocationResponse)new DataContractJsonSerializer(typeof(YahooLocationResponse)).ReadObject(resultStream);
                if (null != onPositionChanged)
                    onPositionChanged(this, new PositionEventArgs(this.latitude, this.longitude, this.location,GeoLocationPositionStatus.LocationReceived));
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                if (null != onPositionChanged)
                    onPositionChanged(this, new PositionEventArgs(GeoLocationPositionStatus.ErrorReverseLocation));
            }
            this.gcw.Stop();
            //OK
        }

        public enum AddressPart
        {
            COUNTRY, STATE, POSTALCODE, CITY, DESTRICT, STREET, HOUSENUMBER,
        }

        public static String getFromAddress(YahooLocationResponse address, AddressPart addressPart)
        {
            String part = null;
                if (null != address && null != address.ResultSet && address.ResultSet.Found>0 && null != address.ResultSet.Results && address.ResultSet.Results.Length>0)
                {
                    YahooLocationResponse.ResultSetCont.Result
                        a = address.ResultSet.Results[0];
                    switch (addressPart)
                    {
                        case AddressPart.COUNTRY:
                            part = a.country;
                            break;
                        case AddressPart.STATE:
                            part = a.state;
                            break;
                        case AddressPart.POSTALCODE:
                            part = a.postal;
                            break;
                        case AddressPart.CITY:
                            part = a.city;
                            break;
                        case AddressPart.DESTRICT:
                            part = a.neighborhood;
                            break;
                        case AddressPart.STREET:
                            part = a.street;
                            break;
                        case AddressPart.HOUSENUMBER:
                            part = a.house;
                            break;
                    }
                }
            return part;
        }

        [DataContract]
        public class YahooLocationResponse
        {

            [DataMember]
            public ResultSetCont ResultSet { get; set; }

            [DataContract]
            public class ResultSetCont
            {
                [DataMember]
                public String version { get; set; }
                [DataMember]
                public int Error { get; set; }
                [DataMember]
                public String ErrorMessage { get; set; }
                [DataMember]
                public String Locale { get; set; } //Format: de_DE
                [DataMember]
                public int Quality { get; set; }
                [DataMember]
                public int Found { get; set; }

                [DataMember]
                public Result[] Results { get; set; }

                [DataContract]
                public class Result
                {
                    [DataMember]
                    public int quality { get; set; }
                    [DataMember]
                    public String latitude { get; set; }
                    [DataMember]
                    public String longitude { get; set; }
                    [DataMember]
                    public String offsetlat { get; set; }
                    [DataMember]
                    public String offsetlon { get; set; }
                    [DataMember]
                    public int radius { get; set; }
                    [DataMember]
                    //return search term ... 
                    //if you search by geo coordinates it'll give you geo coordinates like "52.551366,13.420663"
                    //if you search by name ...then
                    public String name { get; set; }
                    [DataMember]
                    public String line1 { get; set; }//"Scherenbergstrasse 19"
                    [DataMember]
                    public String line2 { get; set; }//"10439 Berlin"
                    [DataMember]
                    public String line3 { get; set; }
                    [DataMember]
                    public String line4 { get; set; }//"Deutschland"
                    [DataMember]
                    public String house { get; set; } //"19"
                    [DataMember]
                    public String street { get; set; }
                    [DataMember]
                    public String xstreet { get; set; }
                    [DataMember]
                    public String unittype { get; set; }
                    [DataMember]
                    public String unit { get; set; }
                    [DataMember]
                    public String postal { get; set; }//"10439"
                    [DataMember]
                    public String neighborhood { get; set; }//"Prenzlauer Berg"
                    [DataMember]
                    public String city { get; set; }//"Berlin"
                    [DataMember]
                    public String county { get; set; }//"Berlin"
                    [DataMember]
                    public String state { get; set; }//"Berlin"
                    [DataMember]
                    public String country { get; set; }//"Deutschland"
                    [DataMember]
                    public String countrycode { get; set; }//"DE"
                    [DataMember]
                    public String statecode { get; set; }//"BE"
                    [DataMember]
                    public String countycode { get; set; }//"BE"
                    [DataMember]
                    public String hash { get; set; }
                    [DataMember]
                    public String woeid { get; set; }
                    [DataMember]
                    public int woetype { get; set; }
                    [DataMember]
                    public String uzip { get; set; }//"10439"
                }
            }
        }
    }
}
