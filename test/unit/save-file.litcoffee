# `saveFile` module

	describe "saveFile", ->

		saveFile = require "../../source/save-file"

## What?

**`saveFile`** provides useful abstractions for saving text and binary files.

## How?

#### API

```CoffeeScript
saveFile = require "./save-file"

saveFile.saveText
	text: "Hello, world!"
	filename: "hw.txt"
```

#### Use modern JavaScript features: `Blob` and `saveAs`.

This module uses `Blob` with
[a polyfill](https://www.npmjs.com/package/blob-polyfill) and `saveAs` with
[a polyfill](https://www.npmjs.com/package/filesaver.js).

## `saveFile.download`

Usage:

```CoffeeScript
saveFile.download
	url: "http://vk.com/favicon.ico"
	callback: ( err, file ) ->
```

Downloads a file and returns it as an `ArrayBuffer` to the callback.

		describe "download", ->

			it "should return an Error when no url is provided", ( done ) ->
				saveFile.download
					callback: ( err, file ) ->
						expect( file ).to.not.be.ok
						err.should.be.an.instanceof Error
						done()

			it "should return an Error when no callback is provided", ->
				result = saveFile.download
					url: "whatever"
				result.should.be.an.instanceof Error

			it "should download the file using ajax.get", ( done ) ->
				ajax = require "../../source/ajax"

				fakeCallback = ( err, file ) ->
					expect( err ).to.not.be.ok
					file.should.equal "fake-buffer"
					ajax.get.restore()
					done()

				# This is how a real result from `ajax.get` looks.
				fakeResult =
					response:
						response: "fake-buffer"

				sinon.stub ajax, "get", ({ url, responseType, callback }) ->
					url.should.equal "fake-url"
					responseType.should.equal "arraybuffer"
					# `ajax.get` returns result text as the first argument.
					# Obviously, there's no text when downloading binary files.
					callback null, fakeResult

				saveFile.download
					url: "fake-url"
					callback: fakeCallback

			it "should return an Error when no buffer in response", ( done ) ->
				ajax = require "../../source/ajax"

				fakeCallback = ( err, file ) ->
					err.should.be.an.instanceof Error
					expect( file ).to.not.be.ok
					ajax.get.restore()
					done()

				# This is how a real result from `ajax.get` looks.
				fakeResult =
					error: "Oops, no buffer!"

				sinon.stub ajax, "get", ({ url, responseType, callback }) ->
					url.should.equal "fake-url"
					responseType.should.equal "arraybuffer"
					callback null, fakeResult

				saveFile.download
					url: "fake-url"
					callback: fakeCallback

## `saveFile.saveText`

		describe "saveText", ->

			# TODO: Use a proxyquire-like tool to mock Blob and saveAs. See #177.
			it "exists", ->
				saveFile.saveText.should.be.a "function"
