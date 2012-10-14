$(document).bind("mobileinit", function() {
	$.support.cors = true;
    $.mobile.buttonMarkup.hoverDelay = 0;
    $.mobile.allowCrossDomainPages = true;
    $.mobile.pushStateEnabled = false;
    
    $.mobile.autoInitializePage = false;
    $.mobile.defaultPageTransition = 'none';
    $.mobile.touchOverflowEnabled = false;
    $.mobile.defaultDialogTransition = 'none';
    $.mobile.loadingMessage = '' ;
});