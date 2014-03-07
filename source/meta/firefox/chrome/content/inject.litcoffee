	init = ->
		return unless gBrowser

		processOpenedWindow = ({ originalTarget }) ->
			return unless originalTarget.nodeName is "#document"

			doc = originalTarget
			win = doc.defaultView
			url = doc.location.href

			return unless win is win.top
			return if -1 is url.indexOf "://vk.com/"

			done = ( response ) -> win.postMessage response, "*"
			win.addEventListener "message", ( makeAjaxRequest done ), no

			# See: content_script.js:23
			inject doc, "window._ext_ldr_vkopt_loader = true", isSource: yes

			# See: background.js:10 and gulpfile.js
			inject doc, "dist.js"

		gBrowser.addEventListener "DOMContentLoaded", processOpenedWindow, no

	loadListener = ->
		window.removeEventListener "load", loadListener
		init()

	window.addEventListener "load", loadListener, no
