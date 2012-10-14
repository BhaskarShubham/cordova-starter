/*<daniele.pecora>*/
//requires to be loaded after cordova.x.x.x.js and AsyncCD.js
//this one requires AsyncCD.js (asynchronous cross domain request)
var getReverseLocation = function(){
            var sucCall=function (p){
                var gpsurl='http://nominatim.openstreetmap.org/reverse?format=json&lat='
                	.concat(p.coords.latitude)
                	.concat('&lon=')
                	.concat(p.coords.longitude)
                	.concat('&zoom=18&addressdetails=1');
                var successCallback=function(resultJSON){
                	//result is expected as JSON
                    try{
            		var city=resultJSON['address']['city'];
                    var city_district=resultJSON['address']['city_district'];
                    alert('city:'.concat(city).concat('\n').concat('district:').concat(city_district));
                    }catch(e){
                        errorCallback(e.message);
                    }
                };
                var errorCallback=function(error){
                        alert('failed:\n'.concat(error));
                };
                AsyncCD.getJSON(gpsurl,successCallback, errorCallback);
            };
    var locFail = function() {
        alert('getting current location failed!');
    };
    navigator.geolocation.getCurrentPosition(sucCall, locFail);
};
/*</daniele.pecora>*/