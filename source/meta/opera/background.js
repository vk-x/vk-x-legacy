// This script runs in background and has a permission
// to do cross-origin ajax requests.
// See: index.html.
opera.extension.onmessage = function( messageEvent ) {
	// This function provides old interface for cross-origin ajax
	// until new one won't be implemented.
	// See: vk_ext_api object defined in vk_lib.js
	var data = messageEvent.data,
		requestType = data.act.toUpperCase(),
		sub = data._sub;
	if ([ "GET", "POST", "HEAD" ].indexOf( requestType ) !== -1 ) {
		request = new XMLHttpRequest();
		request.open( requestType, data.url, true );
		request.onload = function() {
			if ( this.status >= 200 && this.status < 400 ) {
				var response = this.response;
				if ( requestType === "HEAD" ) {
					response = this.getAllResponseHeaders();
				}
				messageEvent.source.postMessage({
					response: { response: response },
					sub: sub
				});
			}
		};
		request.send();
	}
};
