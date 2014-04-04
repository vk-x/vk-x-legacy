	app = require "../../../../app"
	handleAjax = require "../../../handle-ajax"

	inject = ( target, script, { isSource } = {}) ->
		tag = target.createElement "script"
		if isSource
			tag.textContent = script
		else
			tag.src = "resource://#{app.name}/#{script}"
			tag.charset = "UTF-8"
		( target.head ? target.documentElement ).appendChild tag

	processOpenedWindow = ({ doc, win, url }) ->
		return unless /^http(s)?:\/\/([a-z0-9\.]+\.)?vk\.com\//.test url

		win.addEventListener "message", handleAjax, no

		# See: content_script.js:23
		inject doc, "window._ext_ldr_vkopt_loader = true", isSource: yes

		# See: background.js:10 and gulpfile.js
		inject doc, "run-in-top.js" if win is win.top

		inject doc, "run-in-frames.js" if win isnt win.top

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
