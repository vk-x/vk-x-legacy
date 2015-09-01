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
				wrappedDone = ->
					queue.doneCount += 1
					queue._afterEach? filename, queue.doneCount, queue.totalCount
					done()

				if url?
					saveFile.download
						url: url
						callback: ( err, file ) ->
							if err?
								queue.error? err
							else
								zip.file filename, file
							wrappedDone()

				else if text?
					zip.file filename, text
					setTimeout wrappedDone

			queue.concurrency = concurrency ? 3
			queue.totalCount = 0
			queue.doneCount = 0

			queue.add = ( task, callback ) ->
				queue.totalCount += 1
				queue.push task, callback

			queue.zip = ( callback ) ->
				queue.drain = ->
					callback zip.generate type: "blob"

			queue.afterEach = ( callback ) ->
				queue._afterEach = callback

			queue

## `saveFile.saveText`

		saveText: ({ text, filename } = {}) ->
			blob = new Blob [ text ], type: "text/plain;charset=utf-8"
			saveAs blob, filename

	module.exports = saveFile
