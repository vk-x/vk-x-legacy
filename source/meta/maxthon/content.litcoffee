	handleAjax = require "../handle-ajax"
	inject = require "../inject"

	window.addEventListener "message", handleAjax, no

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
