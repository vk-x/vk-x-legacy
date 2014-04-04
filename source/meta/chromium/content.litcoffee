	handleAjax = require "../handle-ajax"

	window.addEventListener "message", handleAjax, no

	# http://stackoverflow.com/a/9517879
	inject = ( script, { isSource } = {}) ->
		tag = document.createElement "script"
		if isSource
			tag.textContent = script
		else
			tag.src = chrome.extension.getURL script
		tag.charset = "UTF-8"
		( document.head ? document.documentElement ).appendChild tag

	# See: content_script.js:23
	inject "window._ext_ldr_vkopt_loader = true", isSource: yes

	# See: background.js:10 and gulpfile.litcoffee
	inject "run-in-top.js" if window is window.top

	inject "run-in-frames.js" if window isnt window.top
