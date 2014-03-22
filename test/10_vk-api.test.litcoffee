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

```CoffeeScript
app.vkApi.getAccessToken callback: ( accessToken ) -> alert accessToken
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

## app.vkApi.getAccessToken

**`app.vkApi.getAccessToken`** is an async method to get the
[session access token](http://vk.com/dev/auth_mobile).

		describe "getAccessToken", ->

#### It fetches access token and passes it to callback.

			it "should fetch token and pass it to callback", ( done ) ->

We use [Sinon](http://sinonjs.org/) stubs to spy on `_performAuth`.  
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
