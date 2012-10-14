//some little plugin to change buttons state with less code
(function( $ ) {
  $.fn.changeState = function(options) {
	    // Create some defaults, extending them with any options that were provided
	    var settings = $.extend( {
	      'state': 'primary',
	      'text' : '...'
	    }, options);
	  var __baseclass='btn btn-large span1 ';
	  var _classes={
			  primary:(__baseclass.concat('btn-primary')),
			  loading:(__baseclass),
			  success:(__baseclass.concat('btn-success')),
			  danger:(__baseclass.concat('btn-danger'))
			  };
	  this.attr('class',_classes[settings['state']]);
	  this.text(settings['text']);
  };
})( jQuery );

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
    			_b.attr('class','btn btn-large btn-success span1');
    			var cd=loc_city.concat(', ').concat(loc_district);
    			_b.text('Aktueller Standort: ' + cd); 
    			
    			label_location.text(cd);
        	}else{
        		var _b=$('#btn_location');
        	}
        	$('#btn_reload').text(text_load);
        	$('#btn_reload,#lnk_location_reload,#label_location').click(function(){
        		var rl_succes=function(city,district,lat,lon){
        			saveCityDestrict(city,district,lat,lon);
        			var cd=city.concat(', ').concat(district);
        			$('#btn_location').changeState({state:'success',text:'Aktueller Standort: '+cd});
        			$('#btn_reload').changeState({state:'primary',text:text_load});
        			label_location.text(cd);
        			lnk_location_reload.text(text_location_reload);
        		};
        		var rl_error=function(error){
        			$('#btn_location').changeState({state:'danger',text:error});
        			lnk_location_reload.text(text_location_reload);
        		};
        		
        		$('#btn_reload').changeState({state:'loading',text:text_loading});
        		$('#btn_location').changeState({state:'loading',text:$('#btn_location').text()});
        		label_location.text(text_loading);
        		lnk_location_reload.text(text_wait);
        		getReverseLocation(rl_succes,rl_error);
        	});
        	
        	$('#btn_location').click(function() {
        		history.back();
        		return false;
        	});

        	var gotoMap=function(){
            	var loc_city = window.localStorage.getItem("loc_city");
            	var loc_district = window.localStorage.getItem("loc_district");
            	var loc_lat = window.localStorage.getItem("loc_lat");
            	var loc_lon = window.localStorage.getItem("loc_lon");
        	    var url = 'http://maps.google.com/maps?';
        	    url += 'q='+loc_city+' '+loc_district;
        	    url += '&near=';
        	    url += loc_lat;
        	    url += ',';
        	    url += loc_lon;
        	    url += '&z=15';
        	    // open the native maps app by calling window location
        	    window.location = url;
        	    
        	};      
        	$('#btn_map').click(gotoMap);
        }
        document.addEventListener('deviceready', appReadyCallback, false);        