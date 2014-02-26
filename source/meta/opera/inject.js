// ==UserScript==
// @include http://vk.com/*
// @exclude http://vk.com/notifier.php*
// @exclude http://vk.com/*_frame.php*
// ==/UserScript==

// Opera 12 does not allow to access resources from web,
// so script file injection is only possible with background
// script which does have access to local resources.
// Originally VkOpt used background script which loaded source files
// and passed them to this script as strings. They were then
// eval'ed here.
// Now we use gulp to concat source code and inject it below.

window.addEventListener( "message", function( messageEvent ) {
	var data = messageEvent.data;
	if ( data.mark === "vkopt_loader" ) {
		// This function should provide old interface for
		// cross-origin ajax until new one won't be implemented.
		// See: ex_api.on_message in content_script.js
		// and ext_api in background.js
		console.log( data );
	}
}, false );

// See: content_script.js:23
window._ext_ldr_vkopt_loader = true;

// Although this file runs in the page context, there're some
// weird errors when trying to run source code without eval().
// Needs further investigation cause eval() is too slow to leave it so.

// See: gulpfile.js
window.eval( "This will be replaced with the contents of source/ folder" );
