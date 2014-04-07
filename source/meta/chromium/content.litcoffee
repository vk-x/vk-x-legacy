	app = require "../../app"
	performRequest = require( "../../ajax/perform-request" ) app
	inject = require "../inject"

	handleBackgroundAjax = ({ data, source }) ->
		callback = ( responseData ) ->
			source.postMessage responseData, "*"
		performRequest { data, source, callback }

	window.addEventListener "message", handleBackgroundAjax, no

	# See: content_script.js:23
	inject "window._ext_ldr_vkopt_loader = true", isSource: yes

	# See: background.js:10 and gulpfile.litcoffee
	inject "run-in-top.js" if window is window.top

	inject "run-in-frames.js" if window isnt window.top
