[tests]: ../test/unit/saveFile.litcoffee

**Note**: see [tests][tests] for API documentation.
This file only contains notes on internal details.

# `saveFile` module

	Blob = require "blob"
	saveAs = require "filesaver.js"
	ajax = require "./ajax"
	async = require "async"
	JsZip = require "jszip"

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

## `saveFile.saveMultipleAsZip`

		saveMultipleAsZip: ({ concurrency } = {}) ->
			zip = new JsZip

			queue = async.queue ({ url, text, filename }, done ) ->
				if url?
					saveFile.download
						url: url
						callback: ( err, file ) ->
							if err?
								queue.error? err
							else
								zip.file filename, file
							done()
				else if text?
					zip.file filename, text
					setTimeout done

			queue.concurrency = concurrency ? 3
			queue.add = queue.push
			queue.zip = ( callback ) ->
				queue.drain = ->
					callback zip.generate type: "blob"
			queue

## `saveFile.saveText`

		saveText: ({ text, filename } = {}) ->
			blob = new Blob [ text ], type: "text/plain;charset=utf-8"
			saveAs blob, filename

	module.exports = saveFile
