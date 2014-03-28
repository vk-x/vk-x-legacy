# app.dislike

	describe "app.dislike", ->

## What?

**`app.dislike`** provides interface for... suddenly, **dislike** management.

## Why?

Why not? Many VkOpt users use dislikes.

## How?

#### API

```CoffeeScript
# Just any unique string you prefer for current object.
objectUniqueId = "photo12345_12345"

app.dislike.request
	target: objectUniqueId
	dislike: yes # "yes" by default. Pass "no" to undo dislike.
	callback: -> alert "Dislike set successfully!"

app.dislike.count
	target: objectUniqueId
	callback: ({ count, isDisliked }) -> alert "Dislikes: #{count}."

app.dislike.list
	target: objectUniqueId
	limit: 6 # default is 6
	offset: 0 # default is 0
	callback: ({ count, users }) ->
		alert "Total dislikes: #{count}"
		alert "First one is id#{ users[ 0 ] }"
```

There're shortcuts:
```CoffeeScript
app.dislike.add target: "object_id", callback: ->
app.dislike.remove target: "object_id", callback: ->
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
			app.dislike.APP_ID.should.be.a "number"

## app.dislike.request
**`app.dislike.request`** is the main dislike method.

#### _fetchWidgetHtml helper

		describe "_fetchWidgetHtml", ->

			it "should fetch widget html and pass it to callback", ( done ) ->
				sinon.stub app.ajax, "post", ({ url, data, callback } = {}) ->
					url.should.equal "https://vk.com/widget_like.php"
					data.should.deep.equal
						app: "foo"
						url: "target/for/dislike"
					# Defer callback execution to mimic async process.
					setTimeout -> callback "bar"

				app.dislike._fetchWidgetHtml
					appId: "foo"
					targetUrl: "target/for/dislike"
					callback: ( html ) ->
						html.should.equal "bar"
						app.ajax.post.restore()
						done()

#### _parseHashValues helper

		describe "_parseHashValues", ->

			it "should extract hashes and return them", ->
				html = "_pageQuery = '123abc'; likeHash = '456def'"
				hashes = app.dislike._parseHashValues html
				hashes.should.deep.equal
					pageQuery: "123abc"
					likeHash: "456def"

			it "should throw on invalid html", ->
				html = "_pageQuery = 'lolwtf'; likeHash = 5"
				( -> app.dislike._parseHashValues html )
					.should.throw "app.dislike.request - invalid widget html!"

#### _getHashValues helper

		describe "_getHashValues", ->

			beforeEach -> app.dislike._hashValuesCache = {}

			it "should _fetchWidgetHtml, _parseHashValues, and cache results",
				( done ) ->
					fakeWidgetHtml = "fake html"
					fakeAppId = "fake app id"
					fakeTargetUrl = "fake target url"
					fakeHashValues =
						pageQuery: "fake pageQuery"
						likeHash: "fake hash"

					sinon.stub app.dislike, "_fetchWidgetHtml",
						({ appId, targetUrl, callback } = {}) ->
							appId.should.equal fakeAppId
							targetUrl.should.equal fakeTargetUrl
							# Defer callback execution to mimic async process.
							setTimeout -> callback fakeWidgetHtml

					sinon.stub app.dislike, "_parseHashValues", ( html ) ->
						html.should.equal fakeWidgetHtml
						fakeHashValues

					app.dislike._getHashValues
						appId: fakeAppId
						targetUrl: fakeTargetUrl
						callback: ( hashValues ) ->
							hashValues.should.deep.equal fakeHashValues
							app.dislike._fetchWidgetHtml
								.should.have.been.calledOnce
							app.dislike._parseHashValues
								.should.have.been.calledOnce
							
							# Second call, should use cache.
							app.dislike._getHashValues
								appId: fakeAppId
								targetUrl: fakeTargetUrl
								callback: ( hashValues ) ->
									hashValues.should.deep.equal fakeHashValues
									app.dislike._fetchWidgetHtml
										.should.have.been.calledOnce
									app.dislike._parseHashValues
										.should.have.been.calledOnce
									app.dislike._fetchWidgetHtml.restore()
									app.dislike._parseHashValues.restore()
									done()

#### _performLikeRequest helper

		describe "_performLikeRequest", ->

			it "should make correct request and then invoke callback",
			( done ) ->
				sinon.stub app.ajax, "post",
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

				app.dislike._performLikeRequest
					appId: "foo"
					hashValues:
						pageQuery: "fake pageQuery"
						likeHash: "fake hash"
					dislike: 1
					callback: ->
						app.ajax.post.restore()
						done()

#### app.dislike.request itself

		describe "request", ->

#### It uses helpers to apply dislike.

			it "should use helpers to apply dislike", ( done ) ->

				sinon.stub app.dislike, "_getHashValues",
					({ appId, targetUrl, callback } = {}) ->
						appId.should.equal app.dislike.APP_ID
						targetUrl.should.equal app.dislike.BASE_URL +
							"fake object"
						# Defer callback execution to mimic async process.
						setTimeout -> callback
							pageQuery: "fake pageQuery"
							likeHash: "fake hash"

				sinon.stub app.dislike, "_performLikeRequest",
					({ appId, hashValues, dislike, callback }) ->
						appId.should.equal app.dislike.APP_ID
						hashValues.should.deep.equal
							pageQuery: "fake pageQuery"
							likeHash: "fake hash"
						dislike.should.equal 1
						# Defer callback execution to mimic async process.
						setTimeout callback

				app.dislike.request
					target: "fake object"
					dislike: yes
					callback: ->
						app.dislike._getHashValues.should.have.been.called
						app.dislike._getHashValues.restore()
						app.dislike._performLikeRequest.should.have.been.called
						app.dislike._performLikeRequest.restore()
						done()

#### It assumes `dislike` is `true` by default.

			it "should use \"dislike: yes\" by default", ( done ) ->
				sinon.stub app.dislike, "_fetchWidgetHtml", ({ callback }) ->
					callback "_pageQuery = '123abc'; likeHash = '456def'"

				sinon.stub app.dislike, "_performLikeRequest", ({ dislike }) ->
						dislike.should.equal 1
						app.dislike._fetchWidgetHtml.restore()
						app.dislike._performLikeRequest.restore()
						done()

				app.dislike.request target: "fake object"

#### It requires `target` to be specified.

			it "should throw when no target specified", ->
				app.dislike.request.should.throw "Dislike target not specified!"

## app.dislike.add
**`app.dislike.add`** is an alias for `app.dislike.request dislike: yes`

		describe "add", ->
			it "should set dislike to yes", ( done ) ->
				sinon.stub app.dislike, "request", ({ dislike, target }) ->
						dislike.should.equal yes
						target.should.equal "fake object"
						app.dislike.request.restore()
						done()

				app.dislike.add target: "fake object"


## app.dislike.remove
**`app.dislike.remove`** is an alias for `app.dislike.request dislike: no`

		describe "remove", ->
			it "should set dislike to no", ( done ) ->
				sinon.stub app.dislike, "request", ({ dislike, target }) ->
						dislike.should.equal no
						target.should.equal "fake object"
						app.dislike.request.restore()
						done()

				app.dislike.remove target: "fake object"

## app.dislike.count
**`app.dislike.count`** is a shortcut for the corresponding `app.vkApi` call.

This is the source code of `execute.dislikeSummary` stored function:
```JavaScript
// This stored function returns { count, isDisliked }
var dislikes = API.likes.getList({
    type: "sitepage",
    owner_id: Args.appId,
    page_url: Args.targetUrl
});
if ( dislikes ) {
    var count = dislikes.count;
    var dislikeUserIds = dislikes.items;
    var currentUserId = API.users.get()[ 0 ].id;
    var isDisliked = false;
    // likes.isLiked method requires item_id which can't be page url,
    // it's easier to iterate through dislikes and see if current user
    // is on the list.
    // P.S. Yes, there's no Array::indexOf.
    var i = 0;
    if ( count > 0 ) {
    	// TODO: Handle objects with more than 100 dislikes.
        while ( i < count ) {
            if ( dislikeUserIds[ i ] == currentUserId ) {
                isDisliked = true;
            }
            i = i + 1;
        }
    }
    return { count: count, isDisliked: isDisliked };
} else {
    return { count: 0, isDisliked: false };
}
```

Back to tests.

		describe "count", ->

			beforeEach -> app.dislike._dislikeCountCache = {}

			it "should make correct app.vkApi.request call", ( done ) ->
				sinon.stub app.vkApi, "request", ({ method, data, callback }) ->
						method.should.equal "execute.dislikeSummary"
						data.should.deep.equal
							appId: app.dislike.APP_ID
							targetUrl: app.dislike.BASE_URL + "fake object"

						# Defer callback execution to mimic async process.
						setTimeout callback response: count: 5, isDisliked: yes

				app.dislike.count
					target: "fake object"
					callback: ({ count, isDisliked }) ->
						app.vkApi.request.should.have.been.called
						app.vkApi.request.restore()
						count.should.equal 5
						isDisliked.should.equal yes
						done()

			it "should cache results", ( done ) ->
				sinon.stub app.vkApi, "request", ({ method, data, callback }) ->

						# Defer callback execution to mimic async process.
						setTimeout callback response: count: 5, isDisliked: yes

				app.dislike.count
					target: "fake object"
					callback: ({ count, isDisliked }) ->
						app.vkApi.request.should.have.been.called
						count.should.equal 5
						isDisliked.should.equal yes

						# Second call, should use cache.
						app.dislike.count
							target: "fake object"
							callback: ({ count, isDisliked }) ->
								app.vkApi.request.should.have.been.calledOnce
								app.vkApi.request.restore()
								count.should.equal 5
								isDisliked.should.equal yes
								done()

#### It requires `target` to be specified.

			it "should throw when no target specified", ->
				app.dislike.count.should.throw "Dislike target not specified!"

## app.dislike.list
**`app.dislike.list`** is a shortcut for the corresponding `app.vkApi` call.

		describe "list", ->

			it "should make correct app.vkApi.request call", ( done ) ->
				sinon.stub app.vkApi, "request", ({ method, data, callback }) ->
					method.should.equal "likes.getList"
					data.should.deep.equal
						type: "sitepage"
						page_url: app.dislike.BASE_URL + "fake target"
						owner_id: app.dislike.APP_ID
						count: "fake count"
						offset: "fake offset"

					# Defer callback execution to mimic async process.
					setTimeout callback response:
						count: "fake count"
						items: [ 10, 20, 30 ]

				app.dislike.list
					target: "fake target"
					limit: "fake count"
					offset: "fake offset"
					callback: ({ count, users }) ->
						app.vkApi.request.should.have.been.called
						app.vkApi.request.restore()
						count.should.equal "fake count"
						users.should.deep.equal [ 10, 20, 30 ]
						done()

			it "should use sane defaults", ( done ) ->
				sinon.stub app.vkApi, "request", ({ method, data, callback }) ->
					method.should.equal "likes.getList"
					data.should.deep.equal
						type: "sitepage"
						page_url: app.dislike.BASE_URL + "fake target"
						owner_id: app.dislike.APP_ID
						count: 6
						offset: 0

					# Defer callback execution to mimic async process.
					setTimeout callback response:
						count: "fake count"
						items: [ 10, 20, 30 ]

				app.dislike.list
					target: "fake target"
					callback: ({ count, users }) ->
						app.vkApi.request.should.have.been.called
						app.vkApi.request.restore()
						count.should.equal "fake count"
						users.should.deep.equal [ 10, 20, 30 ]
						done()

			it "should throw when no target specified", ->
				app.dislike.list.should.throw "Dislike target not specified!"

			it "should return safe defaults to callback", ( done ) ->
				sinon.stub app.vkApi, "request", ({ method, data, callback }) ->
					method.should.equal "likes.getList"
					data.should.deep.equal
						type: "sitepage"
						page_url: app.dislike.BASE_URL + "fake target"
						owner_id: app.dislike.APP_ID
						count: 6
						offset: 0

					# Defer callback execution to mimic async process.
					setTimeout callback error: "wrong target url, silly you"

				app.dislike.list
					target: "fake target"
					callback: ({ count, users }) ->
						app.vkApi.request.should.have.been.called
						app.vkApi.request.restore()
						count.should.equal 0
						users.should.deep.equal []
						done()
