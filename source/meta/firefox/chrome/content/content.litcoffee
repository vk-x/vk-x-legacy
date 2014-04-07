	app = require "../../../../app"
	performRequest = require( "../../../../ajax/perform-request" ) app
	inject = require "../../../inject"

	handleBackgroundAjax = ({ data, source }) ->
		callback = ( responseData ) ->
			source.postMessage responseData, "*"
		performRequest { data, source, callback }

	processOpenedWindow = ({ doc, win, url }) ->
		return unless /^http(s)?:\/\/([a-z0-9\.]+\.)?vk\.com\//.test url

		win.addEventListener "message", handleBackgroundAjax, no

		# See: content_script.js:23
		inject "window._ext_ldr_vkopt_loader = true", target: doc, isSource: yes

		# See: background.js:10 and gulpfile.js
		inject "run-in-top.js", target: doc if win is win.top

		inject "run-in-frames.js", target: doc if win isnt win.top

Magic and all the Mozilla-fu taken from VkOpt.
This is done intentionally to handle new windows before load,
i.e. before `onload` and `DOMContentLoaded`.

	Components.classes[ "@mozilla.org/observer-service;1" ]
		.getService Components.interfaces.nsIObserverService
		.addObserver observe: ( obj, eventType ) ->
			return unless eventType is "document-element-inserted"
			doc = obj
			return unless doc.location?
			win = doc.defaultView
			url = doc.location.href

			processOpenedWindow doc: doc, win: win, url: url
		, "document-element-inserted", no
