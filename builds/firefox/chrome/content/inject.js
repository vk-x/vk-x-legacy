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

				win.addEventListener( "message", function( messageEvent ) {
					var data = messageEvent.data;
					if ( data.mark === "vkopt_loader" ) {
						// This function should provide old interface for
						// cross-origin ajax until new one won't be implemented.
						// See: ex_api.on_message in content_script.js
						// and ext_api in background.js
						win.console.log( data );
					}
				}, false );

				if ( isTopWindow ) {
					// See: content_script.js:23
					injectScript( doc, "window._ext_ldr_vkopt_loader = true",
						{ isSource: true });

					// See: background.js:10 and gulpfile.js
					injectScript( doc, "happy.js" );
				}
			}, false );
		}
	};

window.addEventListener( "load", function load() {
	window.removeEventListener( "load", load, false );
	init();
}, false );
