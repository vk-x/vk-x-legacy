# app.vkApi

	describe "app.vkApi", ->

## What?

**`app.vkApi`** provides interface for
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
app.vkApi.getAccessToken callback: ( accessToken ) -> alert accessToken
```

[**`request`**](http://vk.com/dev/auth_mobile)

All options are required.

```CoffeeScript
app.vkApi.request
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

**`app.vkApi.*`** if needed creates **`<iframe>`** tag and appends in to
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

		beforeEach -> app.vkApi._accessToken = null

## Application meta info

		it "should have APP_ID", ->
			app.vkApi.APP_ID.should.be.a "number"

## app.vkApi.getAccessToken

**`app.vkApi.getAccessToken`** is an async method to get the
[session access token](http://vk.com/dev/auth_mobile).

#### _performAuth helper

		describe "_performAuth", ->

			it "should create an iframe and listen for the token", ( done ) ->

`vkCe` is a function used to *Create element* - iframe in our case.

				sinon.stub window, "vkCe", ( elementType, attributes ) ->
					elementType.should.equal "iframe"
					attributes.src.should.be.a "string"
					attributes.id.should.be.a "string"
					attributes.style.should.equal "display: none"
					"fake element"

				sinon.stub document.body, "appendChild", ( element ) ->
					element.should.equal "fake element"

				authRequestId = app.vkApi._performAuth
					callback: ( accessToken ) ->
						accessToken.should.equal "fake token"
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

#### app.vkApi.getAccessToken itself

		describe "getAccessToken", ->

#### It fetches access token and passes it to callback.

			it "should fetch token and pass it to callback", ( done ) ->

`_performAuth` should be called only once as the result should be cached.

				isFakeAuthCalled = no
				sinon.stub app.vkApi, "_performAuth", ({ callback } = {}) ->
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
					app.vkApi._performAuth.restore()
					done()

Let's rock.

				app.vkApi.getAccessToken callback: fakeCallback

#### It caches the token.

			it "should cache the token", ( done ) ->
 
`_performAuth` should be called only once as the result should be cached.

				isFakeAuthCalled = no
				fakeAuth =
				sinon.stub app.vkApi, "_performAuth", ({ callback } = {}) ->
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

				app.vkApi.getAccessToken callback: ( accessToken ) ->
					fakeCallback accessToken
					app.vkApi.getAccessToken callback: ( accessToken ) ->
						fakeCallback accessToken
						app.vkApi.getAccessToken callback: ( accessToken ) ->
							fakeCallback accessToken

## app.vkApi.request

**`app.vkApi.request`** is an async method to make
[a request to VK API](http://vk.com/dev/api_requests).

It is actually just a wrapper for `app.vkApi.getAccessToken`
and `app.ajax.get`.

		describe "request", ->

#### It gets access token and calls `app.ajax.get`.

			it "should fetch token and call app.ajax.get", ( done ) ->

				sinon.stub app.vkApi, "getAccessToken", ({ callback } = {}) ->
					# Defer callback execution to mimic async process.
					setTimeout -> callback "fake token"

				sinon.stub app.ajax, "get", ({ url, data, callback } = {}) ->
					url.should.equal "https://api.vk.com/method/users.get"
					data.should.deep.equal
						foo: "bar"
						access_token: "fake token"
						v: app.vkApi._apiVersion
					# Defer callback execution to mimic async process.
					setTimeout -> callback "{\"online\":0}", {}

`callback` should be called only once. It should get `online: 0`
as an argument.

				isFakeCallbackCalled = no
				fakeCallback = ( result ) ->
					isFakeCallbackCalled.should.equal no
					isFakeCallbackCalled = yes
					result.should.deep.equal online: 0
					app.vkApi.getAccessToken.restore()
					app.ajax.get.restore()
					done()

Let's rock.

				app.vkApi.request
					method: "users.get"
					data: foo: "bar"
					callback: fakeCallback

#### It allows to omit `data` and `callback` options.

			it "should have \"data\" and \"callback\" optional", ( done ) ->

				sinon.stub app.vkApi, "getAccessToken", ({ callback } = {}) ->
					# Defer callback execution to mimic async process.
					setTimeout -> callback "fake token"

				sinon.stub app.ajax, "get", ({ url, data, callback } = {}) ->
					url.should.equal "https://api.vk.com/method/users.get"
					data.should.deep.equal
						access_token: "fake token"
						v: app.vkApi._apiVersion
					done()

				app.vkApi.request
					method: "users.get"

#### It throws when `method` is missing.

			it "should throw when \"method\" is missing", ->

				( -> app.vkApi.request data: {}, callback: -> )
					.should.throw "app.vkApi.request - method is missing!"
