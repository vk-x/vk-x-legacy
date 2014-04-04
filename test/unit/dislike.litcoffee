# `dislike` module

	describe "dislike", ->

		app = require "../../source/app"
		ajax = require( "../../source/ajax" ) app
		vkApi = require( "../../source/vk-api" ) app, ajax
		dislike = null
		beforeEach -> dislike = require( "../../source/dislike" ) ajax, vkApi

## What?

**`dislike`** module provides interface for, suddenly, **dislike** management.

## Why?

Why not? Many VkOpt users use dislikes.

## How?

#### API

```CoffeeScript
app = require "./app"
ajax = require( "./ajax" ) app
vkApi = require( "./vk-api" ) app, ajax
dislike = require( "./dislike" ) ajax, vkApi

# Just any unique string you prefer for current object.
objectUniqueId = "photo12345_12345"

dislike.request
	target: objectUniqueId
	dislike: yes # "yes" by default. Pass "no" to undo dislike.
	callback: -> alert "Dislike set successfully!"

dislike.count
	target: objectUniqueId
	callback: ({ count, isDisliked }) -> alert "Dislikes: #{count}."

dislike.list
	target: objectUniqueId
	limit: 6 # default is 6
	offset: 0 # default is 0
	callback: ({ count, users }) ->
		alert "Total dislikes: #{count}"
		alert "First one is id#{ users[ 0 ] }"
```

There're shortcuts:
```CoffeeScript
dislike.add target: "object_id", callback: ->
dislike.remove target: "object_id", callback: ->
```

Only `target` is required in all methods.

#### Use existing Like APIs internally.

We can store only very limited amount of variables globally for VK application,
so we can't store dislikes that way.

There're no public APIs for setting arbitrary attributes on objects like
posts or photos.

But consider this: VK have a [Like widget](http://vk.com/dev/Like)
for external sites *and it doesn't check whether liked page exists*.
It also doesn't check whether the "like" request is being sent from
that external site or not.

So let's go VkOpt way: store dislikes as likes for some unique
nonexistent pages.  
VK doesn't provide public API for likes on external sites apart from
[Like widget](http://vk.com/dev/Like), but it is really easy to mimic
that widget, it only performs one request.
Here's how:

- **Fetch Like widget html**:  
	Make a POST request to https://vk.com/widget_like.php, include POST data:
	- `url` - unique url which identifies object being disliked
	- `app` - VK application ID. This app must be of "site" type, and its
	base url must be set and prepended to `url` param

- **Parse two hash values from widget html**:  
	Split `_pageQuery` and `likeHash` variable values from html. These are
	required for the final request which applies like for the fake page.

- **Perform exactly the same request as the widget does**:  
	Make a POST request to https://vk.com/widget_like.php?act=a_like,
	include POST data:
	- `app` - the same app ID as in the first request
	- `hash` - value of `likeHash`
	- `pageQuery` - value of `_pageQuery`
	- `value` - `1` to apply like or `0` to undo it

To get dislikes we can use regular
[`likes.getList`](http://vk.com/dev/likes.getList) API method.

## Application meta info

		it "should have APP_ID", ->
			dislike.APP_ID.should.be.a "number"

## dislike.request
**`dislike.request`** is the main dislike method.

#### _fetchWidgetHtml helper

		describe "_fetchWidgetHtml", ->

			it "should fetch widget html and pass it to callback", ( done ) ->
				sinon.stub ajax, "post", ({ url, data, callback } = {}) ->
					url.should.equal "https://vk.com/widget_like.php"
					data.should.deep.equal
						app: "foo"
						url: "target/for/dislike"
					# Defer callback execution to mimic async process.
					setTimeout -> callback "bar"

				dislike._fetchWidgetHtml
					appId: "foo"
					targetUrl: "target/for/dislike"
					callback: ( html ) ->
						html.should.equal "bar"
						ajax.post.restore()
						done()

#### _parseHashValues helper

		describe "_parseHashValues", ->

			it "should extract hashes and return them", ->
				html = "_pageQuery = '123abc'; likeHash = '456def'"
				hashes = dislike._parseHashValues html
				hashes.should.deep.equal
					pageQuery: "123abc"
					likeHash: "456def"

			it "should throw on invalid html", ->
				html = "_pageQuery = 'lolwtf'; likeHash = 5"
				( -> dislike._parseHashValues html )
					.should.throw "dislike.request - invalid widget html!"

#### _getHashValues helper

		describe "_getHashValues", ->

			it "should _fetchWidgetHtml, _parseHashValues, and cache results",
				( done ) ->
					fakeWidgetHtml = "fake html"
					fakeAppId = "fake app id"
					fakeTargetUrl = "fake target url"
					fakeHashValues =
						pageQuery: "fake pageQuery"
						likeHash: "fake hash"

					sinon.stub dislike, "_fetchWidgetHtml",
						({ appId, targetUrl, callback } = {}) ->
							appId.should.equal fakeAppId
							targetUrl.should.equal fakeTargetUrl
							# Defer callback execution to mimic async process.
							setTimeout -> callback fakeWidgetHtml

					sinon.stub dislike, "_parseHashValues", ( html ) ->
						html.should.equal fakeWidgetHtml
						fakeHashValues

					dislike._getHashValues
						appId: fakeAppId
						targetUrl: fakeTargetUrl
						callback: ( hashValues ) ->
							hashValues.should.deep.equal fakeHashValues
							dislike._fetchWidgetHtml
								.should.have.been.calledOnce
							dislike._parseHashValues
								.should.have.been.calledOnce
							
							# Second call, should use cache.
							dislike._getHashValues
								appId: fakeAppId
								targetUrl: fakeTargetUrl
								callback: ( hashValues ) ->
									hashValues.should.deep.equal fakeHashValues
									dislike._fetchWidgetHtml
										.should.have.been.calledOnce
									dislike._parseHashValues
										.should.have.been.calledOnce
									dislike._fetchWidgetHtml.restore()
									dislike._parseHashValues.restore()
									done()

#### _performLikeRequest helper

		describe "_performLikeRequest", ->

			it "should make correct request and then invoke callback",
			( done ) ->
				sinon.stub ajax, "post",
					({ url, data, callback, query } = {}) ->
						url.should.equal "https://vk.com/widget_like.php"
						query.should.deep.equal act: "a_like"
						data.should.deep.equal
							app: "foo"
							hash: "fake hash"
							pageQuery: "fake pageQuery"
							value: 1
						# Defer callback execution to mimic async process.
						setTimeout -> callback "weird redirected page html"

				dislike._performLikeRequest
					appId: "foo"
					hashValues:
						pageQuery: "fake pageQuery"
						likeHash: "fake hash"
					dislike: 1
					callback: ->
						ajax.post.restore()
						done()

#### dislike.request itself

		describe "request", ->

#### It uses helpers to apply dislike.

			it "should use helpers to apply dislike", ( done ) ->

				sinon.stub dislike, "_getHashValues",
					({ appId, targetUrl, callback } = {}) ->
						appId.should.equal dislike.APP_ID
						targetUrl.should.equal dislike.BASE_URL +
							"fake object"
						# Defer callback execution to mimic async process.
						setTimeout -> callback
							pageQuery: "fake pageQuery"
							likeHash: "fake hash"

				dislikeModule = dislike
				sinon.stub dislike, "_performLikeRequest",
					({ appId, hashValues, dislike, callback }) ->
						appId.should.equal dislikeModule.APP_ID
						hashValues.should.deep.equal
							pageQuery: "fake pageQuery"
							likeHash: "fake hash"
						dislike.should.equal 1
						# Defer callback execution to mimic async process.
						setTimeout callback

				dislike.request
					target: "fake object"
					dislike: yes
					callback: ->
						dislike._getHashValues.should.have.been.called
						dislike._getHashValues.restore()
						dislike._performLikeRequest.should.have.been.called
						dislike._performLikeRequest.restore()
						done()

#### It assumes `dislike` is `true` by default.

			it "should use \"dislike: yes\" by default", ( done ) ->
				sinon.stub dislike, "_fetchWidgetHtml", ({ callback }) ->
					callback "_pageQuery = '123abc'; likeHash = '456def'"

				dislikeModule = dislike
				sinon.stub dislike, "_performLikeRequest", ({ dislike }) ->
						dislike.should.equal 1
						dislikeModule._fetchWidgetHtml.restore()
						dislikeModule._performLikeRequest.restore()
						done()

				dislike.request target: "fake object"

#### It requires `target` to be specified.

			it "should throw when no target specified", ->
				dislike.request.should.throw "Dislike target not specified!"

## dislike.add
**`dislike.add`** is an alias for `dislike.request dislike: yes`

		describe "add", ->
			it "should set dislike to yes", ( done ) ->
				dislikeModule = dislike
				sinon.stub dislike, "request", ({ dislike, target }) ->
						dislike.should.equal yes
						target.should.equal "fake object"
						dislikeModule.request.restore()
						done()

				dislike.add target: "fake object"


## dislike.remove
**`dislike.remove`** is an alias for `dislike.request dislike: no`

		describe "remove", ->
			it "should set dislike to no", ( done ) ->
				dislikeModule = dislike
				sinon.stub dislike, "request", ({ dislike, target }) ->	
					dislike.should.equal no
					target.should.equal "fake object"
					dislikeModule.request.restore()
					done()

				dislike.remove target: "fake object"

## dislike.count
**`dislike.count`** is a shortcut for the corresponding `vkApi` call.

This is the source code of `execute.dislikeSummary` stored function:
```JavaScript
// Function signature: { appId, targetUrl } > { count, isDisliked }
var dislikeList = API.likes.getList({
	type: "sitepage",
	owner_id: Args.appId,
	page_url: Args.targetUrl,
	count: 1
});
if ( dislikeList ) {
	var isDisliked = false;
	if ( dislikeList.count > 0 ) {
		var currentUserId = API.users.get()[ 0 ].id;
		var firstDislikedId = dislikeList.items[ 0 ];
		if ( currentUserId == firstDislikedId ) {
			isDisliked = true;
		}
	}
	return { count: dislikeList.count, isDisliked: isDisliked };
} else {
	return { count: 0, isDisliked: false };
}
```

Back to tests.

		describe "count", ->

			beforeEach -> dislike._dislikeCountCache = {}

			it "should make correct vkApi.request call", ( done ) ->
				sinon.stub vkApi, "request", ({ method, data, callback }) ->
						method.should.equal "execute.dislikeSummary"
						data.should.deep.equal
							appId: dislike.APP_ID
							targetUrl: dislike.BASE_URL + "fake object"

						# Defer callback execution to mimic async process.
						setTimeout callback response: count: 5, isDisliked: yes

				dislike.count
					target: "fake object"
					callback: ({ count, isDisliked }) ->
						vkApi.request.should.have.been.called
						vkApi.request.restore()
						count.should.equal 5
						isDisliked.should.equal yes
						done()

			it "should cache results", ( done ) ->
				sinon.stub vkApi, "request", ({ method, data, callback }) ->

						# Defer callback execution to mimic async process.
						setTimeout callback response: count: 5, isDisliked: yes

				dislike.count
					target: "fake object"
					callback: ({ count, isDisliked }) ->
						vkApi.request.should.have.been.called
						count.should.equal 5
						isDisliked.should.equal yes

						# Second call, should use cache.
						dislike.count
							target: "fake object"
							callback: ({ count, isDisliked }) ->
								vkApi.request.should.have.been.calledOnce
								vkApi.request.restore()
								count.should.equal 5
								isDisliked.should.equal yes
								done()

#### It requires `target` to be specified.

			it "should throw when no target specified", ->
				dislike.count.should.throw "Dislike target not specified!"

## dislike.list
**`dislike.list`** is a shortcut for the corresponding `app.vkApi` call.

		describe "list", ->

			it "should make correct vkApi.request call", ( done ) ->
				sinon.stub vkApi, "request", ({ method, data, callback }) ->
					method.should.equal "likes.getList"
					data.should.deep.equal
						type: "sitepage"
						page_url: dislike.BASE_URL + "fake target"
						owner_id: dislike.APP_ID
						count: "fake count"
						offset: "fake offset"

					# Defer callback execution to mimic async process.
					setTimeout callback response:
						count: "fake count"
						items: [ 10, 20, 30 ]

				dislike.list
					target: "fake target"
					limit: "fake count"
					offset: "fake offset"
					callback: ({ count, users }) ->
						vkApi.request.should.have.been.called
						vkApi.request.restore()
						count.should.equal "fake count"
						users.should.deep.equal [ 10, 20, 30 ]
						done()

			it "should use sane defaults", ( done ) ->
				sinon.stub vkApi, "request", ({ method, data, callback }) ->
					method.should.equal "likes.getList"
					data.should.deep.equal
						type: "sitepage"
						page_url: dislike.BASE_URL + "fake target"
						owner_id: dislike.APP_ID
						count: 6
						offset: 0

					# Defer callback execution to mimic async process.
					setTimeout callback response:
						count: "fake count"
						items: [ 10, 20, 30 ]

				dislike.list
					target: "fake target"
					callback: ({ count, users }) ->
						vkApi.request.should.have.been.called
						vkApi.request.restore()
						count.should.equal "fake count"
						users.should.deep.equal [ 10, 20, 30 ]
						done()

			it "should throw when no target specified", ->
				dislike.list.should.throw "Dislike target not specified!"

			it "should return safe defaults to callback", ( done ) ->
				sinon.stub vkApi, "request", ({ method, data, callback }) ->
					method.should.equal "likes.getList"
					data.should.deep.equal
						type: "sitepage"
						page_url: dislike.BASE_URL + "fake target"
						owner_id: dislike.APP_ID
						count: 6
						offset: 0

					# Defer callback execution to mimic async process.
					setTimeout callback error: "wrong target url, silly you"

				dislike.list
					target: "fake target"
					callback: ({ count, users }) ->
						vkApi.request.should.have.been.called
						vkApi.request.restore()
						count.should.equal 0
						users.should.deep.equal []
						done()
