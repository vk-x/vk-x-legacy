[tests]: ../test/unit/saveFile.litcoffee

**Note**: see [tests][tests] for API documentation.
This file only contains notes on internal details.

# `saveFile` module

	# Applies polyfill immediately, no method call needed.
	require "blob-polyfill"

	saveAs = require "filesaver.js"
	ajax = require "./ajax"

	saveFile =

## `saveFile.download`

		download: ({ url, callback } = {}) ->
			if not callback
				return new Error "No callback is provided!"

			if not url
				callback new Error "No URL is provided!"
				return

			ajax.get
				url: url
				responseType: "arraybuffer"
				callback: ( text, result ) ->
					if result?.response?.response
						callback null, result.response.response
					else
						callback new Error "Error while downloading!"

## `saveFile.saveText`

		saveText: ({ text, filename } = {}) ->
			blob = new Blob [ text ], type: "text/plain;charset=utf-8"
			saveAs blob, filename

	module.exports = saveFile
