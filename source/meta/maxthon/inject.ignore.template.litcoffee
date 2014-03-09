	inject = ( script ) ->
		tag = document.createElement "script"
		tag.textContent = script
		( document.head ? document.documentElement ).appendChild tag

	handleAjax = ({ data }) ->
		return unless data.requestOf is "<%= name %>"

		superagent data.method, data.url
			.set data.headers
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
