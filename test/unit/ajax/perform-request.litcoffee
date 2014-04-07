# ajax/performRequest function

	describe "ajax/performRequest", ->

		app = require "../../../source/app"
		uri = require "../../../source/uri"
		performRequest = null
		beforeEach -> performRequest =
			require( "../../../source/ajax/perform-request" ) app

## What?

**`ajax/performRequest`** module **performs ajax requests**.

## Why?

This function lives in a separate module to keep things DRY: it's used in
`ajax` module (for same-origin requests) and in background scripts
(for cross-origin requests).

This is an internal module. Use `ajax` module instead.

## How?

#### API

```CoffeeScript
app = require "./app"
performRequest = require( "./ajax/perform-request" ) app

callback = ( response, meta ) -> if meta.status is 200 then alert response

performRequest
	data:
		method: "GET"
		url: "http://example.com/"
		data: to: "send"
		query: params: "to apply"
		headers: to: "set"
		_requestId: "request id"
		requestOf: app.name
	source: window
	callback: callback
```

All options are required.  
See `test/unit/ajax.litcoffee` for more information about the options.

Requests are done using http://visionmedia.github.io/superagent internally.

#### Mock up XMLHttpRequest for each test.
You can look into `requests` to see all requests made from the start
of current test.

		xhr = null
		requests = null

		beforeEach ->
			requests = []
			xhr = sinon.useFakeXMLHttpRequest()
			xhr.onCreate = ( xhr ) -> requests.push xhr

		afterEach -> xhr.restore()

#### It uses xhr for same-origin requests:

		it "should use xhr for same-origin request", ( done ) ->
			requestData =
				method: "POST"
				url: "http://example.com/"
				data: to: "send"
				query: params: "to set"
				headers: custom: "one"
				requestOf: app.name
				_requestId: "1"

			callback = ({ url, method, responseOf, _requestId, response }) ->
				response.text.should.equal "foo"
				method.should.equal requestData.method
				url.should.equal requestData.url
				responseOf.should.equal requestData.requestOf
				_requestId.should.equal requestData._requestId
				response.ok.should.be.ok
				done()

			performRequest
				data: requestData
				source: window
				callback: callback

			requests.length.should.equal 1
			requests[ 0 ].url.should.equal requestData.url + "?params=to%20set"
			requests[ 0 ].method.should.equal "POST"
			requests[ 0 ].requestBody.should.equal "to=send"
			requests[ 0 ].requestHeaders.custom.should.equal "one"

			requests[ 0 ].respond 200,
				"Content-Type": "application/text"
			, "foo"
