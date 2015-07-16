	app = require "../../app"
	performRequest = require "../../ajax/perform-request"
	inject = require "../inject"

	handleBackgroundAjax = ({ data, source }) ->
		callback = ( responseData ) ->
			source.postMessage responseData, "*"
		performRequest.performRequest { data, source, callback }

	window.addEventListener "message", handleBackgroundAjax, no

	# See: background.js:10 and gulpfile.litcoffee
	inject "run-in-top.js" if window is window.top
	inject "run-in-frames.js" if window isnt window.top
