[tests]: ../../test/unit/ajax/perform-request.litcoffee

**Note**: see [tests][tests] for API documentation.
This file only contains notes on internal details.

	superagent = require "superagent"
	app = require "../app"
	url = require "url"

	performRequest = ({ data, source, callback }) ->
		return unless data.requestOf is app.name

		# Opera 12 denies to access source.location in background
		# See: source/meta/opera/includes/content.litcoffee
		sourceUrl = source.location?.href ? data.sourceUrl
		absoluteUrl = url.resolve sourceUrl, data.url

		req = superagent data.method, absoluteUrl
			.set data.headers
			.query data.query
			.type "form"

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

			callback responseData

	module.exports = { performRequest }
