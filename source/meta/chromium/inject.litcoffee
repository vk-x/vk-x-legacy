	# This provides old interface for cross-origin ajax
	# until new one won't be implemented.
	# See: ./helpers.litcoffee
	done = ( response ) -> window.postMessage response, "*"
	window.addEventListener "message", ( makeAjaxRequest done ), no

	# See: content_script.js:23
	inject "window._ext_ldr_vkopt_loader = true", isSource: yes

	# See: background.js:10 and gulpfile.litcoffee
	inject "dist.js"
