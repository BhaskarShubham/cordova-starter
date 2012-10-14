/*
 * daniele.pecora
 */
/* Atrocious way of loading different cordova scripts. */
var userAgent = navigator.userAgent.toLowerCase();
var cordova_xloader_jscript_to_load="phonegap.js";
/*
default script phonegap.js does auto load the right os version. (not tested)
it is included by the cordova project and does not have to exists in project.
*/
var xloader_navigator_type=0;
/*
* 1=android
* 2=applewebkit
* 3=msie
*/
if (userAgent.match(/android/)) {
	cordova_xloader_jscript_to_load="cordova-android-2.0.0.js";
	xloader_navigator_type=1;
} else if(userAgent.match(/applewebkit/)){
	cordova_xloader_jscript_to_load="cordova-ios-2.0.0.js";
	xloader_navigator_type=2;
} else if(userAgent.match(/msie/) || userAgent.match(/windows/)){
	cordova_xloader_jscript_to_load="cordova-wp7-2.0.0.js";
	xloader_navigator_type=3;
}
//just some informations what the webview user agent is
//document.write("<p>"+navigator.userAgent+"<p>");
//just some information on wich cordova file is beeing loaded
//document.write("<p>"+cordova_xloader_jscript_to_load+"<p>");
document.write("<script type='text/javascript' src='"+cordova_xloader_jscript_to_load+"'><\/script>");

/* redefine alert for those navigators they haven't an alert system (wp7)*/
if(xloader_navigator_type==3){
	window.alert = navigator.notification.alert;
}