[tests]: ../test/unit/vk-api.litcoffee

**Note**: see [tests][tests] for API documentation.
This file only contains notes on internal details.

# `vkApi` module

	_ = require "lodash"

	vkApi = ( app, ajax ) ->

## Private API

		apiAppInfo =
			id: 4238625
			permissions: [
				"audio"
				"docs"
				"friends"
				"groups"
				"messages"
				"notes"
				"pages"
				"photos"
				"stats"
				"status"
				"video"
				"wall"
			]

		apiVersion = "5.16"

		authUrlParams =
			client_id: apiAppInfo.id
			scope: apiAppInfo.permissions.join ","
			redirect_uri: encodeURIComponent "https://oauth.vk.com/blank.html"
			display: "popup"
			v: apiVersion
			response_type: "token"

		authUrl = "https://oauth.vk.com/authorize?" +
			( "#{param}=#{value}" for param, value of authUrlParams ).join "&"

		requestBaseUrl = "https://api.vk.com/method/"

## "Public" API

Although these fields are exposed as public, it is strongly recommended to only
use those without an undersore (`_`).
Private methods are here for testing purposes only (see [tests][tests]).

		_apiVersion: apiVersion

		_performAuth: ({ callback } = {}) ->
			callback ?= ->
			authRequestId = _.uniqueId()
			authFrame = window.vkCe "iframe",
				src: authUrl
				# Chrome, Opera and Maxthon read window.name from id.
				id: "#{app.name}-auth-frame-#{authRequestId}"
				# Firefox reads window.name from name.
				name: "#{app.name}-auth-frame-#{authRequestId}"
				style: "display: none"

			listener = ({ data }) ->
				if data.oauthMessageOf is app.name and
				data._requestId is authRequestId
					callback data.accessToken

			window.addEventListener "message", listener, no

			window.document.body.appendChild authFrame

			authRequestId

#### Application meta info

You may use this meta data.

		APP_ID: apiAppInfo.id

#### `vkApi.getAccessToken`

		_accessToken: null
		_isAuthing: no
		_accessTokenCallbackList: []
		getAccessToken: ({ callback, force } = {}) ->
			callback ?= ->
			if @_accessToken and not force
				callback @_accessToken
			else
				@_accessTokenCallbackList.push callback
				if not @_isAuthing
					@_isAuthing = yes
					context = @
					@_performAuth callback: ( accessToken ) ->
						context._accessToken = accessToken
						context._isAuthing = no
						for callback in context._accessTokenCallbackList
							callback accessToken
						context._accessTokenCallbackList = []

#### `vkApi.request`

		_requestQueue: []
		_isBusy: no
		_enqueue: ( requestData ) ->
			@_requestQueue.push requestData
			if not @_isBusy
				@_isBusy = yes
				@_next()

		_next: ->
			if @_requestQueue.length > 0
				req = @_requestQueue.shift()
				originalCallback = req.callback
				context = @
				req.callback = ( args... ) ->
					originalCallback args...
					context._next()
				@_request req
			else
				@_isBusy = no

		_retryDelay: 1000
		_request: ({ method, data, callback }) ->
			requestUrl = requestBaseUrl + method

			context = @
			@getAccessToken callback: ( accessToken ) ->
				data.access_token = accessToken
				do retry = ->
					ajax.get
						url: requestUrl
						data: data
						callback: ( rawResult ) ->
							result = JSON.parse rawResult
							if result.error?.error_code is 6
								setTimeout retry, context._retryDelay
							else
								callback result

		request: ({ method, data, callback } = {}) ->
			throw Error "vkApi.request - method is missing!" if not method

			data ?= {}
			data.v ?= apiVersion
			callback ?= ->

			@_enqueue { method, data, callback }

	module.exports = vkApi
