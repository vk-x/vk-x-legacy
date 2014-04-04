	handleAjax = require "../handle-ajax"
	inject = require "../inject"

	window.addEventListener "message", handleAjax, no

	# See: content_script.js:23
	inject "window._ext_ldr_vkopt_loader = true", isSource: yes

	# See: background.js:10 and gulpfile.litcoffee
	inject "run-in-top.js" if window is window.top

	inject "run-in-frames.js" if window isnt window.top
