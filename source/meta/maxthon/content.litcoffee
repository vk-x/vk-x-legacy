	app = require "../../app"
	performRequest = require( "../../ajax/perform-request" ) app
	inject = require "../inject"

	handleBackgroundAjax = ({ data, source }) ->
		callback = ( responseData ) ->
			source.postMessage responseData, "*"
		performRequest { data, source, callback }

	window.addEventListener "message", handleBackgroundAjax, no

Maxthon 4 does not allow to access files from web, so
script file injection is impossible.

Originally VkOpt used external scripts hosted on VkOpt site,
this file injected them using `<script src="external url">` tag.

Now we use gulp to concat source code and inject it below.

	# See: gulpfile.litcoffee
	sourceForTop = "This will be replaced with the source"
	sourceForFrames = "This will be replaced with the source"

	# See: content_script.js:23
	inject "window._ext_ldr_vkopt_loader = true", isSource: yes

	# See: background.js:10
	if window is window.top
		inject sourceForTop, isSource: yes
	else
		inject sourceForFrames, isSource: yes
