	handleAjax = require "../handle-ajax"

	window.addEventListener "message", handleAjax, no

	inject = ( script ) ->
		tag = document.createElement "script"
		tag.textContent = script
		( document.head ? document.documentElement ).appendChild tag

Maxthon 4 does not allow to access files from web, so
script file injection is impossible.

Originally VkOpt used external scripts hosted on VkOpt site,
this file injected them using `<script src="external url">` tag.

Now we use gulp to concat source code and inject it below.

	# See: gulpfile.litcoffee
	sourceForTop = "This will be replaced with the source"
	sourceForFrames = "This will be replaced with the source"

	# See: content_script.js:23
	inject "window._ext_ldr_vkopt_loader = true"

	# See: background.js:10
	if window is window.top
		inject sourceForTop
	else
		inject sourceForFrames
