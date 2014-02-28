// Maxthon 4 does not allow to access files from web,
// so script file injection is impossible.
// Originally VkOpt used external scripts hosted on VkOpt site,
// this file injected them using <script src="external url"> tag.
// Now we use gulp to concat source code and inject it below.

	// See gulpfile.js
var gulpShouldFillThis = "This will be replaced with the contents of source/",

	injectScript = function( code ) {
		var tag = document.createElement( "script" );
		tag.textContent = code;
		( document.head || document.documentElement ).appendChild( tag );
	};

window.addEventListener( "message", function( messageEvent ) {
	var data = messageEvent.data;
	if ( data.mark === "vkopt_loader" ) {
		// This function should provide old interface for
		// cross-origin ajax until new one won't be implemented.
		// See: ex_api.on_message in content_script.js
		// and ext_api in background.js
		window.console.log( data );
	}
}, false );

// See: content_script.js:23
injectScript( "window._ext_ldr_vkopt_loader = true" );

// See: background.js:10 and gulpfile.js
injectScript( gulpShouldFillThis );
