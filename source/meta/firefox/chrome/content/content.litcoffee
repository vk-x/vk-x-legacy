	app = require "../../../../app"

	inject = ( target, script, { isSource } = {}) ->
		tag = target.createElement "script"
		if isSource
			tag.textContent = script
		else
			tag.src = "resource://#{app.name}/#{script}"
			tag.charset = "UTF-8"
		( target.head ? target.documentElement ).appendChild tag

	handleAjax = ( win ) -> ({ data }) ->
		return unless data.requestOf is app.name

		# https://gist.github.com/Yaffle/1088850 in absolute-url.js
		absoluteUrl = absolutizeURI win.location.href, data.url

		req = superagent data.method, absoluteUrl
			.set data.headers
			.query data.query

		if data.method is "POST"
			req.send data.data
		else
			req.query data.data

		req.end ( response ) ->
			# postMessage() clones data for security reasons.
			# Let's prepare safe clonable properties.
			responseData =
				url: data.url
				method: data.method
				responseOf: app.name
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

	processOpenedWindow = ({ doc, win, url }) ->
		return unless /^http(s)?:\/\/([a-z0-9\.]+\.)?vk\.com\//.test url

		win.addEventListener "message", ( handleAjax win ), no

		# See: content_script.js:23
		inject doc, "window._ext_ldr_vkopt_loader = true", isSource: yes

		# See: background.js:10 and gulpfile.js
		inject doc, "run-in-top.js" if win is win.top

		inject doc, "run-in-frames.js" if win isnt win.top

	Components.classes[ "@mozilla.org/observer-service;1" ]
		.getService Components.interfaces.nsIObserverService
		.addObserver observe: ( obj, eventType ) ->
			return unless eventType is "document-element-inserted"
			doc = obj
			return unless doc.location?
			win = doc.defaultView
			url = doc.location.href

			processOpenedWindow doc: doc, win: win, url: url
		, "document-element-inserted", no
