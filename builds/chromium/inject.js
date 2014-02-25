var isTopWindow = window.top === window,
	prefix = "scripts/";

	// http://stackoverflow.com/a/9517879/1619166
	injectScript = function( data, options ) {
		var options = options || {}, tag;
		if ( isTopWindow || options.runInFrame ) {
			tag = document.createElement( "script" );
			if ( options.isSource ) {
				tag.textContent = data;
			} else {
				tag.src = chrome.extension.getURL( prefix + data );
			}
			( document.head || document.documentElement ).appendChild( tag );
		}
	};

$( window ).on( "message", function( event ) {
	var data = event.originalEvent.data;
	if ( data.mark === "vkopt_loader" ) {
		// This function should provide old interface for cross-origin ajax
		// until new one won't be implemented.
		// See: ex_api.on_message in content_script.js
		// and ext_api in background.js
		console.log( data );
	}
});

// See: content_script.js:23
injectScript( "window._ext_ldr_vkopt_loader = true", { isSource: true });

// See: background.js:10 and gulpfile.js
injectScript( "happy.js" );
