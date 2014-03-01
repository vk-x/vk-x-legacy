// Opera 12 does not allow to access resources from web,
// so script file injection is only possible with background
// script which does have access to local resources.
// Originally VkOpt used background script which loaded source files
// and passed them to this script as strings. They were then
// eval'ed here.
// Now we use gulp to concat source code and inject it below.

// These two event handlers and index.html provide
// old interface for cross-origin ajax until new one won't be implemented.
// See: vk_ext_api object defined in vk_lib.js

opera.extension.addEventListener( "message", function( responseEvent ) {
	window.postMessage( responseEvent.data, "*" );
}, false );

window.addEventListener( "message", function( messageEvent ) {
	if ( messageEvent.data.mark === "vkopt_loader" ) {
		// Pass request to background.js
		opera.extension.postMessage( messageEvent.data );
	}
}, false );

// See: content_script.js:23
window._ext_ldr_vkopt_loader = true;

// Although this file runs in the page context, there're some
// weird errors when trying to run source code without eval().
// Needs further investigation cause eval() is too slow to leave it so.

// See: gulpfile.js
var gulpShouldFillThis = "This will be replaced with the contents of source/";
window.eval( gulpShouldFillThis );
