var isTopWindow = window.top === window;

	// http://stackoverflow.com/a/9517879/1619166
	injectScript = function( data, options ) {
		var options = options || {}, tag;
		if ( isTopWindow || options.runInFrame ) {
			tag = document.createElement( "script" );
			if ( options.isSource ) {
				tag.textContent = data;
			} else {
				tag.src = chrome.extension.getURL( data );
			}
			( document.head || document.documentElement ).appendChild( tag );
		}
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
			// Content scripts can make cross-origin ajax requests.
			// See permissions in manifest.json.
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
injectScript( "window._ext_ldr_vkopt_loader = true", { isSource: true });

// See: background.js:10 and gulpfile.js
injectScript( "dist.js" );
