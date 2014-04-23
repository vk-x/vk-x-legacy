	module.exports = ( app ) ->
		extensionMenuItemHtml: ->
			template = require "./main-menu/extension-menu-item"

			template
				appName: app.name
				appVersion: app.version.full
				isNewVersion: window.localStorage[ app.name + "-new-version" ]
