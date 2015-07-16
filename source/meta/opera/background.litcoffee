This script runs in background and has a permission
to do cross-origin ajax requests.
See: [`source/meta/opera/index.html`](index.html).

	app = require "../../app"
	performRequest = require "../../ajax/perform-request"

	handleBackgroundAjax = ({ data, source }) ->
		callback = ( responseData ) ->
			source.postMessage responseData
		performRequest.performRequest { data, source, callback }

	opera.extension.onmessage = handleBackgroundAjax
