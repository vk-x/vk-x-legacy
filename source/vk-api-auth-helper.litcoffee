	module.exports = ( app ) ->
		if /^http(s)?:\/\/oauth\.vk\.com\/authorize\?/.test location.href
			# Auth page redirects if window.parent && window.parent !== window
			window.parent = null

			# "allow" function is defined somewhere in <head>,
			# but this content scripts runs before it
			# (see Chrome's manifest.json for example)
			# so it most certainly is not defined yet here.
			if allow?
				allow()
			else
				# This page somewhy have invalid html, so that
				# DOMContentReady event isn't being fired.
				intervalId = setInterval ->
					if allow?
						clearInterval intervalId
						allow()
				, 100

		if /^http(s)?:\/\/oauth\.vk\.com\/blank\.html/.test location.href
			message =
				oauthMessageOf: app.name
				_requestId: window.name.replace "#{app.name}-auth-frame-", ""
				accessToken: location.hash
					.match( /access_token=([0-9a-f]*)/ )[ 1 ]

			window.top.postMessage message, "*"
