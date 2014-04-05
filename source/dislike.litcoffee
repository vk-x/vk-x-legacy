**Note**: see tests for API documentation. This file only contains notes
on internal details.

# `dislike` module

	dislike = ( ajax, vkApi ) ->

## Private API

		widgetUrl = "/widget_like.php"

## "Public" API

Although these fields are exposed as public, it is strongly recommended to only
use those without an undersore (`_`).
Private methods are here for testing purposes only (see tests).

		_fetchWidgetHtml: ({ appId, targetUrl, callback }) ->
			ajax.post
				url: widgetUrl
				data:
					app: appId
					url: targetUrl
				callback: callback

		_parseHashValues: ( html ) ->
			try
				_pageQuery = html.match( /_pageQuery = '([a-f0-9]+)'/ )[ 1 ]
				likeHash = html.match( /likeHash = '([a-f0-9]+)'/ )[ 1 ]
			catch
				throw Error "dislike.request - invalid widget html!"

			pageQuery: _pageQuery
			likeHash: likeHash

		_hashValuesCache: {}
		_getHashValues: ({ appId, targetUrl, callback }) ->
			cacheKey = "#{appId}#{targetUrl}"
			if @_hashValuesCache[ cacheKey ]
				callback @_hashValuesCache[ cacheKey ]
			else
				context = @
				@_fetchWidgetHtml
					appId: appId
					targetUrl: targetUrl
					callback: ( response ) ->
						hashValues = context._parseHashValues response
						context._hashValuesCache[ cacheKey ] = hashValues
						callback hashValues

		_performLikeRequest: ({ appId, hashValues, dislike, callback }) ->
			ajax.post
				url: widgetUrl
				query: act: "a_like"
				data:
					app: appId
					hash: hashValues.likeHash
					pageQuery: hashValues.pageQuery
					value: dislike
				callback: -> callback()

		# Algorithm taken from VkOpt. Temporary adapter.
		# TODO: Inject already normalized html.
		_normalizeObjectId: ( rawId ) ->
			return rawId if rawId.match /^([a-z_]+)(-?\d+)_(\d+)/

			matches = rawId.match ///
					( -?\d+ )( _? )
					( photo | video | note | topic | wall_reply |
						note_reply | photo_comment | video_comment |
						topic_comment | )
					( \d+ )
				///
			if matches
				return ( matches[ 3 ] || "wall" ) +
					"#{matches[ 1 ]}_#{matches[ 4 ]}"
			else
				return rawId

#### Application meta info

You may use this meta data.

		# VkOpt original dislike host "site" app ID.
		APP_ID: 3429306

		# VkOpt original dislike base URL.
		BASE_URL: "http://vk.dislike.server/dislike/"

#### dislike.request

		request: ({ target, dislike, callback } = {}) ->
			throw Error "Dislike target not specified!" if not target
			# Dislike by default. Pass "dislike: no" to undo dislike.
			dislike ?= yes
			callback ?= ->

			originalContext = @

			@_getHashValues
				appId: @APP_ID
				targetUrl: @BASE_URL + @_normalizeObjectId target
				callback: ( hashValues ) ->
					originalContext._performLikeRequest
						appId: originalContext.APP_ID
						hashValues: hashValues
						dislike: if dislike then 1 else 0
						callback: callback

#### Shortcuts

		add: ({ target, callback } = {}) ->
			@request target: target, dislike: yes, callback: callback

		remove: ({ target, callback } = {}) ->
			@request target: target, dislike: no, callback: callback

#### dislike.count

		_dislikeCountCache: {}
		count: ({ target, callback } = {}) ->
			throw Error "Dislike target not specified!" unless target
			callback ?= ->
			normalizedTarget = @_normalizeObjectId target

			if @_dislikeCountCache[ normalizedTarget ]
				callback @_dislikeCountCache[ normalizedTarget ]
			else
				context = @
				vkApi.request
					method: "execute.dislikeSummary"
					data:
						appId: @APP_ID
						targetUrl: @BASE_URL + normalizedTarget
					callback: ({ response } = {}) ->
						context._dislikeCountCache[ normalizedTarget ] =
							response
						callback response

#### dislike.list

		list: ({ target, limit, offset, callback } = {}) ->
			throw Error "Dislike target not specified!" unless target
			limit ?= 6
			offset ?= 0
			callback ?= ->
			normalizedTarget = @_normalizeObjectId target

			context = @
			vkApi.request
				method: "likes.getList"
				data:
					type: "sitepage"
					page_url: @BASE_URL + normalizedTarget
					owner_id: @APP_ID
					count: limit
					offset: offset
				callback: ({ response } = {}) ->
					callback
						count: response?.count ? 0
						users: response?.items ? []

	module.exports = dislike
