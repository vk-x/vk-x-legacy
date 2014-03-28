**Note**: see tests for API documentation. This file only contains notes
on internal details.

# app.vkApi

	app.vkApi = do ->

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
Private methods are here for testing purposes only (see tests).

		_apiVersion: apiVersion

		_performAuth: ({ callback } = {}) ->
			callback ||= ->
			authRequestId = app.util.uniqueId()
			authFrame = vkCe "iframe",
				src: authUrl
				id: "#{app.name}-auth-frame-#{authRequestId}"
				style: "display: none"

			listener = ({ data }) ->
				if data.oauthMessageOf is app.name and
				data._requestId is authRequestId
					callback data.accessToken

			window.addEventListener "message", listener, no

			document.body.appendChild authFrame

			authRequestId

#### Application meta info

You may use this meta data.

		APP_ID: apiAppInfo.id

#### app.vkApi.getAccessToken

		_accessToken: null
		_isAuthing: no
		_accessTokenCallbackList: []
		getAccessToken: ({ callback, force } = {}) ->
			callback ||= ->
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

#### app.vkApi.request

		request: ({ method, data, callback } = {}) ->
			throw Error "app.vkApi.request - method is missing!" if not method

			data ?= {}
			data.v ?= apiVersion
			callback ?= ->
			requestUrl = requestBaseUrl + method
			@getAccessToken callback: ( accessToken ) ->
				data.access_token = accessToken
				app.ajax.get
					url: requestUrl
					data: data
					callback: ( response ) -> callback JSON.parse response
