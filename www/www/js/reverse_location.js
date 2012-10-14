/*<daniele.pecora>*/
//requires to be loaded after cordova.x.x.x.js and AsyncCD.js
//this one requires AsyncCD.js (asynchronous cross domain request)
var getReverseLocation = function(successC,errorC){
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
				//alert('city:'.concat(city).concat('\n').concat('district:').concat(city_district));
				if (successC && typeof(successC) === "function") {
					// execute the callback, passing parameters as necessary
					successC(city, city_district, p.coords.latitude, p.coords.longitude);
				}else{console.log('successC callback is not a function')}

			}catch(e){
				errorCallback(e.message);
			}
		};
		var errorCallback=function(e){
			//alert('failed:\n'.concat(e));
			if (errorC && typeof(errorC) === "function") {
				// execute the callback, passing parameters as necessary
				console.log(e);
				errorC('Konnte Standort nicht ermitteln');
			}else{console.log('errorC callback is not a function')}
		};
		AsyncCD.getJSON(gpsurl,successCallback, errorCallback);
	};
    var locFail = function(e) {
        //alert('getting current location failed!');
        if (errorC && typeof(errorC) === "function") {
            // execute the callback, passing parameters as necessary
        	var msg=(e && e.hasOwnProperty('message'))?e.message:e;
			console.log(msg);
			errorC('Konnte Standort nicht ermitteln');
        }else{console.log('locFail callback is not a function')}
    };
    navigator.geolocation.getCurrentPosition(sucCall, locFail);
};
/*</daniele.pecora>*/