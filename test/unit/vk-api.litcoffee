# `vkApi` module

	describe "vkApi", ->

		vkApi = require "../../source/vk-api"

## What?

**`vkApi`** module provides interface for
**[VK application API](http://vk.com/dev/methods)**.

## Why?

VK application API is the easiest way to implement many features. It provides
pure JSON data.

Also, it looks like the only way to get user online status
without throwing him into online.

## How?

#### API

[**`getAccessToken`**](http://vk.com/dev/auth_mobile)

All options are required.

```CoffeeScript
vkApi = require "./vk-api"

vkApi.getAccessToken callback: ( accessToken ) -> alert accessToken
```

[**`request`**](http://vk.com/dev/api_requests)

All options are required.

```CoffeeScript
vkApi.request
	method: "users.get"
	data: fields: "online"
	callback: ({ online }) -> alert if online then "Online" else "Offline"
```

#### Use hidden iframe for authorization.

Although keeping [authorization process](http://vk.com/dev/auth_mobile)
in secret may be considered nasty and rough, it brings better user experience.

[post]: https://developer.mozilla.org/en-US/docs/Web/API/Window.postMessage

Following [the docs on OAuth](http://vk.com/dev/auth_mobile), we create
an **`<iframe>`** with `src` set properly, and run a simple script inside
that `<iframe>` which uses [`window.top.postMessage`][post]
to send **access token** back to main window.

I promise to put a notice about VK app being authorizated without asking.

See [`gulpfile.litcoffee`](../../gulpfile.litcoffee) for more
on which scripts run in top windows and which run in frames.

**P.S.** Yes, I've tried to do it with ajax and without iframes,
it doesn't work.

#### Talk with script in iframe via `message` event on `window`.

Injected to frame script triggers `message` event on `window.top` object,
and injected to top window script captures it.

## Messages specification

#### Request iframe

**`vkApi.*`** if needed creates **`<iframe>`** tag and appends in to
**`document.body`** element like so:
**`document.body.appendChild authFrame`**.

The `authFrame` element is guaranteed to have the following attributes:

- **`src`** - `string` - valid and correct
[OAuth Authorization Dialog](http://vk.com/dev/auth_mobile) URL
- **`style`** - `"display: none"` - hides iframe
- **`id`** - `string` - unique `authFrame` identifier. Available as
`window.name` inside the frame.

#### Response message

Browser extensions are configured to run needed scripts in frames.  
**[`source/vk-api/iframe-auth-helper.litcoffee`]
(../../source/vk-api/iframe-auth-helper.litcoffee)** triggers **`message`**
event on **`window`** object like so:
**`window.postMessage settings, "*"`**.

The `settings` object is guaranteed to have the following properties:

- **`accessToken`** - `string` - VK application API
[access token](http://vk.com/dev/auth_mobile)
- **`oauthMessageOf`** - `string` - you should check that this equals project
name: `return unless message.data.oauthMessageOf is app.name`
- **`_requestId`** - `string` - unique response identifier
equal to `id` attribute specified on `authFrame` element

## Application meta info

		it "should have APP_ID", ->
			vkApi.APP_ID.should.be.a "number"

## `vkApi.getAccessToken`

**`vkApi.getAccessToken`** is an async method to get the
[session access token](http://vk.com/dev/auth_mobile).

#### `_performAuth` helper

		appName = require( "../../source/app" ).name

		describe "_performAuth", ->

			it "should create an iframe and listen for the token", ( done ) ->

`vkCe` is a function used to *Create element* - iframe in our case.

				# A workaround for sinon.wrapMethod until
				# https://github.com/cjohansen/Sinon.JS/pull/449 is merged.
				window.vkCe = ( -> ) unless window.vkCe

				sinon.stub window, "vkCe", ( elementType, attributes ) ->
					elementType.should.equal "iframe"
					attributes.src.should.be.a "string"
					attributes.id.should.be.a "string"
					attributes.name.should.be.a "string"
					attributes.style.should.equal "display: none"
					"fake element"

				sinon.stub document.body, "appendChild", ( element ) ->
					element.should.equal "fake element"

				authRequestId = vkApi._performAuth
					callback: ( accessToken ) ->
						accessToken.should.equal "fake token"
						window.vkCe.restore()
						document.body.appendChild.restore()
						done()

				authRequestId.should.be.a "string"


				window.postMessage
					oauthMessageOf: appName
					_requestId: "#{authRequestId}-incorrect"
					accessToken: "icorrect fake token"
				, "*"

				window.postMessage
					oauthMessageOf: appName
					accessToken: "icorrect fake token"
				, "*"

				window.postMessage
					_requestId: authRequestId
					accessToken: "icorrect fake token"
				, "*"

				window.postMessage
					oauthMessageOf: appName
					_requestId: authRequestId
					accessToken: "fake token"
				, "*"

#### `vkApi.getAccessToken` itself

		describe "getAccessToken", ->

#### It fetches access token and passes it to callback.

			it "should fetch token and pass it to callback", ( done ) ->

`_performAuth` should be called only once as the result should be cached.

				isFakeAuthCalled = no
				sinon.stub vkApi, "_performAuth", ({ callback } = {}) ->
					isFakeAuthCalled.should.equal no
					isFakeAuthCalled = yes
					# Defer callback execution to mimic async process.
					setTimeout -> callback "fake token"

`callback` should be called only once. It should get correct access token
as an argument.

				isFakeCallbackCalled = no
				fakeCallback = ( accessToken ) ->
					isFakeCallbackCalled.should.equal no
					isFakeCallbackCalled = yes
					accessToken.should.equal "fake token"
					vkApi._performAuth.restore()
					vkApi._accessToken = null
					done()

Let's rock.

				vkApi.getAccessToken callback: fakeCallback

#### It caches the token.

			it "should cache the token", ( done ) ->

`_performAuth` should be called only once as the result should be cached.

				isFakeAuthCalled = no
				sinon.stub vkApi, "_performAuth", ({ callback } = {}) ->
					isFakeAuthCalled.should.equal no
					isFakeAuthCalled = yes
					callback.should.be.a "function"
					# Defer callback execution to mimic async process.
					setTimeout -> callback "fake token"

`callback` should be called exactly once for each `getAccessToken` call.
It should also get correct access token as an argument.

				fakeCallbackCalls = 0
				fakeCallback = ( accessToken ) ->
					isFakeAuthCalled.should.equal yes
					fakeCallbackCalls.should.be.lessThan 3
					fakeCallbackCalls += 1
					accessToken.should.equal "fake token"
					if fakeCallbackCalls is 3
						vkApi._performAuth.restore()
						vkApi._accessToken = null
						done()

Let's rock.

				vkApi.getAccessToken callback: ( accessToken ) ->
					fakeCallback accessToken
					vkApi.getAccessToken callback: ( accessToken ) ->
						fakeCallback accessToken
						vkApi.getAccessToken callback: ( accessToken ) ->
							fakeCallback accessToken

#### It doesn't auth multiple times simultaneously.

			it "should auth once at a time", ( done ) ->

`_performAuth` should be called only once.

				isFakeAuthCalled = no
				fakeAuthCallback = null
				sinon.stub vkApi, "_performAuth", ({ callback } = {}) ->
					isFakeAuthCalled.should.equal no
					isFakeAuthCalled = yes
					callback.should.be.a "function"
					fakeAuthCallback = -> callback "fake token"

`callback` should be called exactly once for each `getAccessToken` call.
It should also get correct access token as an argument.

				fakeCallbackCalls = 0
				fakeCallback = ( accessToken ) ->
					isFakeAuthCalled.should.equal yes
					fakeCallbackCalls.should.be.lessThan 3
					fakeCallbackCalls += 1
					accessToken.should.equal "fake token"
					if fakeCallbackCalls is 3
						vkApi._performAuth.restore()
						done()

				vkApi.getAccessToken callback: ( accessToken ) ->
					fakeCallback accessToken
				# Previous call is still waiting for response.
				vkApi.getAccessToken callback: ( accessToken ) ->
					fakeCallback accessToken
				vkApi.getAccessToken callback: ( accessToken ) ->
					fakeCallback accessToken

				# Fire! fakeCallback should be called three times now.
				fakeAuthCallback()

## `vkApi.request`

It is actually a wrapper for `vkApi.getAccessToken` and `ajax.get`
which uses a queue internally in order to make requests sequentially.

**`vkApi.request`** is an async method to make
[a request to VK API](http://vk.com/dev/api_requests).

#### `_request` helper

This is the thin wrapper for `vkApi.getAccessToken` and `ajax.get`.

		ajax = require "../../source/ajax"

		describe "_request", ->

It gets access token and calls `ajax.get`, then invokes callback.

			it "should fetch token and call ajax.get", ( done ) ->

				sinon.stub vkApi, "getAccessToken", ({ callback } = {}) ->
					# Defer callback execution to mimic async process.
					setTimeout -> callback "fake token"

				sinon.stub ajax, "get", ({ url, data, callback } = {}) ->
					url.should.equal "https://api.vk.com/method/users.get"
					data.should.deep.equal
						foo: "bar"
						access_token: "fake token"
					# Defer callback execution to mimic async process.
					setTimeout -> callback "{\"online\":0}", {}

`callback` should be called only once. It should get `online: 0`
as an argument.

				isFakeCallbackCalled = no
				fakeCallback = ( result ) ->
					isFakeCallbackCalled.should.equal no
					isFakeCallbackCalled = yes
					result.should.deep.equal online: 0
					vkApi.getAccessToken.restore()
					ajax.get.restore()
					done()

Let's rock.

				vkApi._request
					method: "users.get"
					data: foo: "bar"
					callback: fakeCallback

It retries in a moment if got "Too many requests per second" error.

			it "should retry when too many requests per second", ( done ) ->

				sinon.stub vkApi, "getAccessToken", ({ callback } = {}) ->
					callback "fake token"

				isFirstTry = yes
				sinon.stub ajax, "get", ({ url, data, callback } = {}) ->
					url.should.equal "https://api.vk.com/method/users.get"
					data.should.deep.equal
						foo: "bar"
						access_token: "fake token"
					if isFirstTry
						isFirstTry = no
						result = error: error_code: 6
					else
						result = response: online: 0
					callback JSON.stringify result

				sinon.stub window, "setTimeout", ( callback, delay ) ->
					delay.should.equal vkApi._retryDelay
					setTimeout.restore()
					# Defer callback execution to mimic timeout.
					setTimeout callback

				isFakeCallbackCalled = no
				fakeCallback = ( result ) ->
					isFakeCallbackCalled.should.equal no
					isFakeCallbackCalled = yes
					result.should.deep.equal response: online: 0
					vkApi.getAccessToken.should.have.been.calledOnce
					vkApi.getAccessToken.restore()
					ajax.get.should.have.been.calledTwice
					ajax.get.restore()
					done()

				vkApi._request
					method: "users.get"
					data: foo: "bar"
					callback: fakeCallback

#### `_enqueue` helper

		describe "_enqueue", ->

It adds request data to the queue.
If the module is not busy (no request is currently performed and the queue is
empty), `_enqueue` also calls `_next` and sets `_isBusy` flag to `yes`.

			it "should enqueues request and calls \"_next\" helper on first
				call", ( done ) ->

					fakeRequestData =
						method: "fake API method"
						data: fake: "API arguments"
						callback: ->

					sinon.stub vkApi, "_next", ->
						vkApi._isBusy.should.equal yes
						vkApi._requestQueue
							.should.deep.equal [ fakeRequestData ]
						vkApi._next.restore()
						vkApi._requestQueue = []
						vkApi._isBusy = no
						done()

					vkApi._enqueue fakeRequestData

It only enqueues request data if `_isBusy` is already `yes`.

			it "should enqueue request when busy", ->

				fakeRequestData =
					method: "fake API method"
					data: fake: "API arguments"
					callback: ->

				sinon.stub vkApi, "_next", -> throw Error "Called '_next'!"

				vkApi._isBusy = yes
				vkApi._enqueue fakeRequestData

				vkApi._requestQueue.should.deep.equal [ fakeRequestData ]
				vkApi._next.restore()
				vkApi._requestQueue = []
				vkApi._isBusy = no

#### `_next` helper

		describe "_next", ->

It gets the first request in the queue using `_requestQueue.shift()` and
passes it to `_request`.  
It also patches callback so that it recursively calls `_next` in the end
to continue sequential queue processing.

			it "should process requests in FIFO style", ( done ) ->

				vkApi._isBusy = yes
				vkApi._requestQueue = [
					{
						method: 1
						data: "fake data"
						callback: ( result ) ->
							result.should.equal 101
					}
					{
						method: 2
						data: "fake data"
						callback: ( result ) ->
							result.should.equal 102
							vkApi._request.restore()
							vkApi._requestQueue = []
							vkApi._isBusy = no
							done()
					}
				]

				expectedRequestNumber = 1
				sinon.stub vkApi, "_request", ({ method, data, callback }) ->
					method.should.equal expectedRequestNumber

					if expectedRequestNumber is 1
						vkApi._requestQueue.length.should.equal 1
					else
						vkApi._requestQueue.length.should.equal 0

					data.should.equal "fake data"

					result = 100 + expectedRequestNumber

					expectedRequestNumber += 1

					# Defer callback execution to mimic timeout.
					setTimeout callback result

				vkApi._next()

It just sets `_isBusy` to `no` if the queue is finally empty.

			it "sets \"_isBusy\" to \"no\" when queue is empty", ->

				vkApi._isBusy = yes
				vkApi._request = -> throw Error "Called '_request'!"
				vkApi._next()
				vkApi._isBusy.should.equal no

#### `vkApi.request` itself

		describe "request", ->

It passes request data to `_enqueue`.

			it "passes request data to \"_enqueue\" helper", ( done ) ->

				fakeRequestData =
					method: "fake API method"
					data: fake: "API arguments"
					callback: ->

				sinon.stub vkApi, "_enqueue", ( requestData ) ->
					requestData.should.deep.equal fakeRequestData
					vkApi._enqueue.restore()
					done()

				vkApi.request fakeRequestData

It allows to omit `data` and `callback` options.

			it "should have \"data\" and \"callback\" optional", ( done ) ->

				sinon.stub vkApi, "_enqueue", ( requestData ) ->
					requestData.method.should.equal "fake API method"
					requestData.data.should.deep.equal v: vkApi._apiVersion
					requestData.callback.should.be.a "function"
					vkApi._enqueue.restore()
					done()

				vkApi.request method: "fake API method"

It throws when `method` is missing.

			it "should throw when \"method\" is missing", ->

				( -> vkApi.request data: {}, callback: -> )
					.should.throw "vkApi.request - method is missing!"
