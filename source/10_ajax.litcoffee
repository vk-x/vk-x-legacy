**Note**: see tests for API documentation. This file only contains notes
on internal details.

# app.ajax
`do` keyword just runs provided function.
[`do ->`](http://coffeescript.org/#try:do -> alert document.title)
is a convenient way to create an
[IIFE](http://en.wikipedia.org/wiki/Immediately-invoked_function_expression)
in CoffeeScript.

	app.ajax = do ->

## app.ajax.request

		request = ( options = {}) ->
			# Keep callback private, do not pass it with request settings.
			callback = options.callback ? ->
			delete options.callback if options.callback

			requestId = app.util.uniqueId app.name

			# These are passed with request event.
			settingsForRequest = app.util.defaults options,
				method: "GET"
				url: ""
				data: {}
			settingsForRequest._requestId = requestId

			# These are passed to callback along with response.
			settingsForCallback = app.util.cloneDeep settingsForRequest

			if settingsForRequest.method in [ "GET", "HEAD" ]
				# Append GET params to url.
				settingsForRequest.url = app.util.uri settingsForRequest.url
					.addQuery settingsForRequest.data
					.href()
				settingsForRequest.data = {}

			listener = ( message ) ->

**Important**: in order to distinguish requests from responses
(both sent via `message` event) background script must add `_responseId`
property to message data with a value of `_requestId` property like so:
`message.data._responseId = message.data._requestId`.

				return unless message.data._responseId is requestId

				# Don't listen anymore when the response arrives.
				window.removeEventListener "message", listener

				# Take only response from message, use sane saved data.
				settingsForCallback.response = message.data.response
				settingsForCallback._responseId = message.data._responseId
				callback settingsForCallback.response, settingsForCallback

			# Listen for response.
			window.addEventListener "message", listener, no

			# Send a request, wait for response.
			window.postMessage settingsForRequest, "*"

## Shortcut methods

		shortcut = {}

		for method in [ "get", "head", "post" ]
			do ( method ) ->
				shortcut[ method ] = ( options = {}) ->
					options.method = method.toUpperCase()
					request options

## Public interface

		request: request
		get: shortcut.get
		head: shortcut.head
		post: shortcut.post
