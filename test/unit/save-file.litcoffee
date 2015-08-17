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

## `saveFile.saveText`

		describe "saveText", ->

			# TODO: Use a proxyquire-like tool to mock Blob and saveAs. See #177.
			it "exists", ->
				saveFile.saveText.should.be.a "function"
