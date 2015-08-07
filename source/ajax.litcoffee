[tests]: ../test/unit/ajax.litcoffee

**Note**: see [tests][tests] for API documentation.
This file only contains notes on internal details.

# `ajax` module

	app = require "./app"
	performRequest = require "./ajax/perform-request"
	_ = require "lodash"
	url = require "url"
	md5 = require "md5-jkmyers"

	cache = {}

	ajax =

## `ajax.request`

		request: ( options = {}) ->
			# Keep callback private, do not pass it with request settings.
			callback = options.callback ? ->
			delete options.callback if options.callback

			requestId = _.uniqueId app.name

			settings = _.defaults options,
				method: "GET"
				url: ""
				responseType: ""
				data: {}
				query: {}
				headers: {}
				cache: off

			if settings.cache is on
				cacheId = md5 JSON.stringify settings

				if cacheId of cache
					data = cache[ cacheId ]
					callback data.response.text, data
					return

			settings._requestId = requestId
			settings.requestOf = app.name

			absoluteUrl = url.resolve location.href, settings.url
			isSameOrigin =
				url.parse( absoluteUrl ).hostname is
				url.parse( location.href ).hostname

			if isSameOrigin
				# Handle request in current context.
				performRequest.performRequest
					data: settings
					source: window
					callback: ( data ) -> callback data.response.text, data
			else
				# Handle request in background script.
				listener = ({ data }) ->

**Important**: in order to distinguish requests from responses
(both sent via `message` event) background script must add `_responseId`
property to message data with a value of `_requestId` property like so:
`message.data._responseId = message.data._requestId`.

					return unless data.responseOf is app.name
					return unless data._requestId is requestId

					# Don't listen anymore when the response arrives.
					window.removeEventListener "message", listener

					if settings.cache is on
						cache[ cacheId ] = data

					callback data.response.text, data

				# Listen for response.
				window.addEventListener "message", listener, no
				# Send a request to background, wait for response.
				window.postMessage settings, "*"

## Shortcut methods

		get: ( options = {}) ->
			options.method = "GET"
			@request options

		head: ( options = {}) ->
			options.method = "HEAD"
			@request options

		post: ( options = {}) ->
			options.method = "POST"
			@request options

	module.exports = ajax
