See `background.litcoffee`.

	makeAjaxRequest = ( callback ) -> ({ data, source }) ->
		return unless data.mark is "vkopt_loader" and data._sub
		
		method = data.act.toUpperCase()
		return unless method in [ "GET", "POST", "HEAD" ]

		requestMetaInfo = data._sub
		url = data.url

		# Overlay scripts can make cross-origin ajax requests.
		request = new XMLHttpRequest
		request.open method, url, yes
		request.onload = ->
			return unless 200 <= @status < 400
			callback source,
				sub: requestMetaInfo
				# That's not a typo! That's how VkOpt works.
				response: response:
					if method is "HEAD"
						@getAllResponseHeaders()
					else
						@response
		request.send()
