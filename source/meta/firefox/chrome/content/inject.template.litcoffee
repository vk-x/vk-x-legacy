	inject = ( target, script, { isSource } = {}) ->
		tag = target.createElement "script"
		if isSource
			tag.textContent = script
		else
			tag.src = "resource://<%= name %>/#{script}"
		( target.head ? target.documentElement ).appendChild tag

	handleAjax = ( win ) -> ({ data }) ->
		return unless data.requestOf is "<%= name %>"

		# https://gist.github.com/Yaffle/1088850 in absolute-url.js
		absoluteUrl = absolutizeURI win.location.href, data.url

		superagent data.method, absoluteUrl
			.set data.headers
			.send data.data
			.end ( response ) ->
				# postMessage() clones data for security reasons.
				# Let's prepare safe clonable properties.
				responseData =
					url: data.url
					method: data.method
					responseOf: "<%= name %>"
					_requestId: data._requestId

				responseData.response = {}
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
					responseData.response[ prop ] = response[ prop ]
				# P.S. There're other properties like "xhr"
				# (raw XMLHttpRequest) which can't be cloned.

				win.postMessage responseData, "*"

	init = ->
		return unless gBrowser

		processOpenedWindow = ({ originalTarget }) ->
			return unless originalTarget.nodeName is "#document"

			doc = originalTarget
			win = doc.defaultView
			url = doc.location.href

			return unless win is win.top
			return if -1 is url.indexOf "://vk.com/"

			win.addEventListener "message", ( handleAjax win ), no

			# See: content_script.js:23
			inject doc, "window._ext_ldr_vkopt_loader = true", isSource: yes

			# See: background.js:10 and gulpfile.js
			inject doc, "dist.js"

		gBrowser.addEventListener "DOMContentLoaded", processOpenedWindow, no

	loadListener = ->
		window.removeEventListener "load", loadListener
		init()

	window.addEventListener "load", loadListener, no
