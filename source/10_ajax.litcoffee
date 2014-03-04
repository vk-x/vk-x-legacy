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

		request = ( settings = {}) ->
			# Save callback privately, do not pass it with request settings.
			callback = settings.callback ? ->
			delete settings.callback if settings.callback

			# Use defaults for omitted settings.
			settings.method ?= "GET"
			settings.url ?= ""
			settings.data ?= {}

			# requestId looks like (app.name + "0.73895393").
			settings._requestId = requestId = app.name + Math.random()

			listener = ( message ) ->

**Important**: in order to distinguish requests from responses
(both sent via `message` event) background script must add `_responseId`
property to message data with a value of `_requestId` property like so:
`message.data._responseId = message.data._requestId`.

				return if message.data._responseId isnt requestId

				# Don't listen anymore when the response arrives.
				window.removeEventListener "message", listener

				# Pass response and full request data to callback.
				callback message.data.response, message.data

			# Listen for response.
			window.addEventListener "message", listener, no

			# Send a request, wait for response.
			window.postMessage settings, "*"

## Shortcut methods

		shortcut = {}

		for method in [ "get", "head", "post" ]
			do ( method ) ->
				shortcut[ method ] = ( settings = {}) ->
					settings.method = method.toUpperCase()
					request settings

## Public interface

		request: request
		get: shortcut.get
		head: shortcut.head
		post: shortcut.post
