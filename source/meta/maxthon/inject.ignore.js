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
	// This function provides old interface for cross-origin ajax
	// until new one won't be implemented.
	// See: vk_ext_api object defined in vk_lib.js
	var data = messageEvent.data;
	if ( data.mark === "vkopt_loader" ) {
		var requestType = data.act.toUpperCase(),
			sub = data._sub;
		if ([ "GET", "POST", "HEAD" ].indexOf( requestType ) !== -1 ) {
			// This extension script can make cross-origin ajax requests.
			// See permissions in def.json.
			request = new XMLHttpRequest();
			request.open( requestType, data.url, true );
			request.onload = function() {
				if ( this.status >= 200 && this.status < 400 ) {
					var response = this.response;
					if ( requestType === "HEAD" ) {
						response = this.getAllResponseHeaders();
					}
					window.postMessage({
						response: { response: response },
						sub: sub
					}, "*" );
				}
			};
			request.send();
		}
	}
}, false );

// See: content_script.js:23
injectScript( "window._ext_ldr_vkopt_loader = true" );

// See: background.js:10 and gulpfile.js
injectScript( gulpShouldFillThis );
