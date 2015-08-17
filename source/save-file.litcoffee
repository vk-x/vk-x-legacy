[tests]: ../test/unit/saveFile.litcoffee

**Note**: see [tests][tests] for API documentation.
This file only contains notes on internal details.

# `saveFile` module

	# Applies polyfill immediately, no method call needed.
	require "blob-polyfill"

	saveAs = require "filesaver.js"

	saveFile =

## `saveFile.saveText`

		saveText: ({ text, filename } = {}) ->
			blob = new Blob [ text ], type: "text/plain;charset=utf-8"
			saveAs blob, filename

	module.exports = saveFile
