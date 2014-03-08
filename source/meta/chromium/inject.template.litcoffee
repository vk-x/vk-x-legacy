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

		superagent data.method, data.url
			.send data.data
			.end ( response ) ->

				delete data.requestOf
				data.responseOf = "<%= name %>"
				# postMessage() clones data for security reasons.
				# Let's prepare safe clonable properties.
				data.response = {}
				safeProperties = [
					"accepted"
					"badRequest"
					"body"
					"charset"
					"clientError"
					"error"
					"forbidden"
					"header"
					"info"
					"noContent"
					"notAcceptable"
					"notFound"
					"ok"
					"serverError"
					"status"
					"statusType"
					"text"
					"type"
					"unauthorized"
				]
				for prop in safeProperties
					data.response[ prop ] = response[ prop ]
				# P.S. There're other properties like "xhr"
				# (raw XMLHttpRequest) which can't be cloned.

				window.postMessage data, "*"

	window.addEventListener "message", handleAjax, no

	# See: content_script.js:23
	inject "window._ext_ldr_vkopt_loader = true", isSource: yes

	# See: background.js:10 and gulpfile.litcoffee
	inject "dist.js"
