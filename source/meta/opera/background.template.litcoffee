This script runs in background and has a permission
to do cross-origin ajax requests.
See: `source/meta/opera/index.html`.

	handleAjax = ({ data, source }) ->
		return unless data.requestOf is "<%= name %>"

		# https://gist.github.com/Yaffle/1088850 in absolute-url.js
		absoluteUrl = absolutizeURI data.sourceUrl, data.url

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

				source.postMessage responseData

	opera.extension.onmessage = handleAjax
