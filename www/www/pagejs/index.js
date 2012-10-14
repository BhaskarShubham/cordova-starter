        var text_loading='Suche Standort...';
        var text_load='Standort ermitteln';
        var text_wait='Bitte warten...';
        var label_location=$('#label_location_text');
        var lnk_location_reload=$('#lnk_location_reload');
        var text_location_reload=lnk_location_reload.text();
        function saveCityDestrict(city, district, lat, lon){
        	var _c=null!=city && city?city:'';
        	var _d=null!=district && district?district:'';
        	var _lat=null!=lat && lat?lat:'';
        	var _lon=null!=lon && lon?lon:'';
        	window.localStorage.setItem("loc_city", _c);
        	window.localStorage.setItem("loc_district", _d);
        	window.localStorage.setItem("loc_lat", _lat);
        	window.localStorage.setItem("loc_lon", _lon);        	
        }
        var appReadyCallback=function(){
        	$('body').button();
        	var loc_city = window.localStorage.getItem("loc_city");
        	var loc_district = window.localStorage.getItem("loc_district");
        	if((null!=loc_city && loc_city) || (null!=loc_district && loc_district)){
        		var _b=$('#btn_location');
    			_b.attr('class','btn btn-large btn-success');
    			var cd=loc_city.concat(', ').concat(loc_district);
    			_b.text(cd); 
    			
    			label_location.text(cd);
        	}else{
	        	$('#btn_location').text(text_load);
        	}
        	$('#btn_location,#lnk_location_reload,#label_location').click(function(){
        		var rl_succes=function(city,district,lat,lon){
        			saveCityDestrict(city,district,lat,lon);
        			b.attr('class','btn btn-large btn-success');
        			var cd=city.concat(', ').concat(district);
        			b.text(cd);
        		
        			label_location.text(cd);
        			lnk_location_reload.text(text_location_reload);
        		};
        		var rl_error=function(error){
        			b.attr('class','btn btn-large btn-danger');
        			b.text(error);
        			lnk_location_reload.text(text_location_reload);
        		};
        		var b=$('#btn_location');
        		b.attr('class','btn btn-large');
        		b.text(text_loading);
        		label_location.text(text_loading);
        		lnk_location_reload.text(text_wait);
        		getReverseLocation(rl_succes,rl_error);
        	});
        }
        document.addEventListener('deviceready', appReadyCallback, false);
