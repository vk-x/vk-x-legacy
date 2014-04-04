# `vkApi` module

	describe "vkApi", ->

		app = require "../../source/app"
		ajax = require( "../../source/ajax" ) app
		vkApi = null
		beforeEach -> vkApi = require( "../../source/vk-api" ) app, ajax

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
app = require "./app"
ajax = require( "./ajax" ) app
vkApi = require( "./vk-api" ) app, ajax

vkApi.getAccessToken callback: ( accessToken ) -> alert accessToken
```

[**`request`**](http://vk.com/dev/auth_mobile)

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

See `gulpfile.litcoffee` for more on which scripts run in top windows and
which run in frames.

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
**`source/run-in-frames/vk-api-auth.litcoffee`** triggers **`message`**
event on **`window`** object like so:
**`window.postMessage settings, "*"`**.

The `settings` object is guaranteed to have the following properties:

- **`accessToken`** - `string` - VK application API
[access token](http://vk.com/dev/auth_mobile)
- **`oauthMessageOf`** - `string` - you should check that this equals project
name: `return unless message.data.oauthMessageOf is app.name`
- **`_requestId`** - `string` - unique response identifier
equal to `id` attribute specified on `authFrame` element

## Reset state before each test

`vkApi` should cache access token. Reset it to `null` so that everything looks
like `vkApi` hasn't been used.

## Application meta info

		it "should have APP_ID", ->
			vkApi.APP_ID.should.be.a "number"

## vkApi.getAccessToken

**`vkApi.getAccessToken`** is an async method to get the
[session access token](http://vk.com/dev/auth_mobile).

#### _performAuth helper

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
					oauthMessageOf: app.name
					_requestId: "#{authRequestId}-incorrect"
					accessToken: "icorrect fake token"
				, "*"

				window.postMessage
					oauthMessageOf: app.name
					accessToken: "icorrect fake token"
				, "*"

				window.postMessage
					_requestId: authRequestId
					accessToken: "icorrect fake token"
				, "*"

				window.postMessage
					oauthMessageOf: app.name
					_requestId: authRequestId
					accessToken: "fake token"
				, "*"

#### vkApi.getAccessToken itself

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
					done()

Let's rock.

				vkApi.getAccessToken callback: fakeCallback

#### It caches the token.

			it "should cache the token", ( done ) ->
 
`_performAuth` should be called only once as the result should be cached.

				isFakeAuthCalled = no
				fakeAuth =
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
					isFakeAuthCalled.should.be. yes
					fakeCallbackCalls.should.be.lessThan 3
					fakeCallbackCalls += 1
					accessToken.should.equal "fake token"
					if fakeCallbackCalls is 3
						fakeAuth.restore()
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

## vkApi.request

**`vkApi.request`** is an async method to make
[a request to VK API](http://vk.com/dev/api_requests).

It is actually just a wrapper for `vkApi.getAccessToken`
and `ajax.get`.

		describe "request", ->

#### It gets access token and calls `ajax.get`.

			it "should fetch token and call ajax.get", ( done ) ->

				sinon.stub vkApi, "getAccessToken", ({ callback } = {}) ->
					# Defer callback execution to mimic async process.
					setTimeout -> callback "fake token"

				sinon.stub ajax, "get", ({ url, data, callback } = {}) ->
					url.should.equal "https://api.vk.com/method/users.get"
					data.should.deep.equal
						foo: "bar"
						access_token: "fake token"
						v: vkApi._apiVersion
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

				vkApi.request
					method: "users.get"
					data: foo: "bar"
					callback: fakeCallback

#### It allows to omit `data` and `callback` options.

			it "should have \"data\" and \"callback\" optional", ( done ) ->

				sinon.stub vkApi, "getAccessToken", ({ callback } = {}) ->
					# Defer callback execution to mimic async process.
					setTimeout -> callback "fake token"

				sinon.stub ajax, "get", ({ url, data, callback } = {}) ->
					url.should.equal "https://api.vk.com/method/users.get"
					data.should.deep.equal
						access_token: "fake token"
						v: vkApi._apiVersion
					vkApi.getAccessToken.restore()
					ajax.get.restore()
					done()

				vkApi.request
					method: "users.get"

#### It throws when `method` is missing.

			it "should throw when \"method\" is missing", ->

				( -> vkApi.request data: {}, callback: -> )
					.should.throw "vkApi.request - method is missing!"

#### It retries in a moment if got "Too many requests per second" error.

			it "should retry when too many requests per second", ( done ) ->

				sinon.stub vkApi, "getAccessToken", ({ callback } = {}) ->
					callback "fake token"

				isFirstTry = yes
				sinon.stub ajax, "get", ({ url, data, callback } = {}) ->
					url.should.equal "https://api.vk.com/method/users.get"
					data.should.deep.equal
						foo: "bar"
						access_token: "fake token"
						v: vkApi._apiVersion
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

				vkApi.request
					method: "users.get"
					data: foo: "bar"
					callback: fakeCallback
