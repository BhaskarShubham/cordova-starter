/* daniele.pecora */
/* this file is a javascript plugin for cordova */
/* it has to have an aquivalent native file for all supported operating systems (Android, IOS and WP7) */
/* this plugin allows cross domain asynchronous JSON requests */

    function _AsyncCD_CheckArgs(win, fail) {
            if(win && typeof win === "function" && fail && typeof fail === "function") {
                    return true;        
            } else {            
				console.log("AsyncCD-Plugin Error: successCallback || errorCallback is not a function");            
                return false;        
            }
	}
    var AsyncCD={
        getJSON:function(url, successCallback, errorCallback)
        {
		   if(_AsyncCD_CheckArgs(successCallback, errorCallback)){
			var _AsyncCD_native_method_arguments = [{"url":url}];
			var _AsyncCD_native_class_name="AsyncCD";
			var _AsyncCD_native_method_name="getJSON";
               var _AsyncCD_succesCallbackWrapper=function(data){
                   var _AsyncCD_tmp_data=data;
                   //assert to return allways a JSON object
                   if(typeof _AsyncCD_tmp_data !='object')
                       _AsyncCD_tmp_data=eval('('+_AsyncCD_tmp_data+')');
                       successCallback(_AsyncCD_tmp_data);
               }
			cordova.exec(_AsyncCD_succesCallbackWrapper, errorCallback, _AsyncCD_native_class_name, _AsyncCD_native_method_name, _AsyncCD_native_method_arguments);
		   }
        }
    }