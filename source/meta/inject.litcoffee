	app = require "../app"

	inject = ( script, { isSource, target } = {}) ->
		target ?= window.document
		tag = target.createElement "script"
		if isSource
			tag.textContent = script
		else
			tag.src =
				chrome?.extension?.getURL( script ) ? # Chromium
				"resource://#{app.name}/#{script}" # Firefox
		# vk.com uses Windows-1251.
		tag.charset = "UTF-8"
		( target.head ? target.documentElement ).appendChild tag

	module.exports = inject
