	# http://stackoverflow.com/a/9517879
	inject = ( script, { isSource } = {}) ->
		tag = document.createElement "script"
		if isSource
			tag.textContent = script
		else
			tag.src = chrome.extension.getURL script
		( document.head ? document.documentElement ).appendChild tag

	handleAjax = ({ data }) ->
		return unless data.requestOf is "<%= name %>"

		request data.method, data.url
			.send data.data
			.end ( response ) ->
				delete data.requestOf
				data.responseOf = "<%= name %>"
				data.response = response

				window.postMessage data, "*"

	window.addEventListener "message", handleAjax, no

	# See: content_script.js:23
	inject "window._ext_ldr_vkopt_loader = true", isSource: yes

	# See: background.js:10 and gulpfile.litcoffee
	inject "dist.js"
