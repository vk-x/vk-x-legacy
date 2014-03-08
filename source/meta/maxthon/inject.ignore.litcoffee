This provides old interface for cross-origin ajax until new one
won't be implemented.  
See: `./helpers.litcoffee`

	done = ( response ) -> window.postMessage response, "*"
	window.addEventListener "message", ( handleOldAjax done ), no

Maxthon 4 does not allow to access files from web, so
script file injection is impossible.

Originally VkOpt used external scripts hosted on VkOpt site,
this file injected them using `<script src="external url">` tag.

Now we use gulp to concat source code and inject it below.

	gulpShouldFillThis = "This will be replaced with the source"

	# See: content_script.js:23
	inject "window._ext_ldr_vkopt_loader = true"

	# See: background.js:10 and gulpfile.litcoffee
	inject gulpShouldFillThis
