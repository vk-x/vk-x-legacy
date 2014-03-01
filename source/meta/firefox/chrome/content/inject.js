var injectScript = function( doc, data, options ) {
		var options = options || {}, tag;
		tag = doc.createElement( "script" );
		if ( options.isSource ) {
			tag.textContent = data;
		} else {
			tag.src = "resource://happy/" + data;
		}
		( doc.head || doc.documentElement ).appendChild( tag );
	},

	// This function provides old interface for cross-origin ajax
	// until new one won't be implemented.
	// See: vk_ext_api object defined in vk_lib.js
	handleMessage = function( messageEvent ) {
		var data = messageEvent.data;
		if ( data.mark === "vkopt_loader" ) {
			var requestType = data.act.toUpperCase(),
				sub = data._sub;
			if ([ "GET", "POST", "HEAD" ].indexOf( requestType ) !== -1 ) {
				// Overlay scripts can make cross-origin ajax requests.
				request = new XMLHttpRequest();
				request.open( requestType, data.url, true );
				request.onload = function() {
					if ( this.status >= 200 && this.status < 400 ) {
						var response = this.response;
						if ( requestType === "HEAD" ) {
							response = this.getAllResponseHeaders();
						}
						win.postMessage({
							response: { response: response },
							sub: sub
						}, "*" );
					}
				};
				request.send();
			}
		}
	},

	init = function() {
		if ( gBrowser ) {
			gBrowser.addEventListener( "DOMContentLoaded", function( e ) {
				if ( e.originalTarget.nodeName !== "#document" ) return;

				var doc = e.originalTarget,
					win = doc.defaultView,
					url = doc.location.href,
					isTopWindow = win === win.top;

				if ( url.indexOf( "http://vk.com/" ) !== 0 &&
					url.indexOf( "https://vk.com/" ) !== 0 ) return;

				if ( url.indexOf( "/notifier.php" ) !== -1 ||
					url.indexOf( "_frame.php" ) !== -1 ) return;

				win.addEventListener( "message", handleMessage, false );

				if ( isTopWindow ) {
					// See: content_script.js:23
					injectScript( doc, "window._ext_ldr_vkopt_loader = true",
						{ isSource: true });

					// See: background.js:10 and gulpfile.js
					injectScript( doc, "dist.js" );
				}
			}, false );
		}
	};

window.addEventListener( "load", function load() {
	window.removeEventListener( "load", load, false );
	init();
}, false );
