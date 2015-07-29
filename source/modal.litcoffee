[tests]: ../test/unit/modal.litcoffee

**Note**: see [tests][tests] for API documentation.
This file only contains notes on internal details.

# `modal` module

	_ = require "lodash"
	template = require "./modal/template"
	progressBarTemplate = require "./modal/progressBarTemplate"
	app = require "./app"
	fs = require "fs"
	logo = "data:image/png;base64," + fs.readFileSync "#{__dirname}/meta/" +
	"logo.png", "base64"

	modal =

		STMANAGER_DEPENDENCIES: [
			"common.css"
			"wkview.js"
			"wkview.css"
			"wk.css"
			"wk.js"
			"page.js"
			"page.css"
			"page_help.css"
		]

## `modal.showPage`

		showPage: ( options = {}) ->
			throw Error "Modal content not specified!" unless options.content
			throw Error "Modal page name not specified!" unless options.pageName

			settings = _.defaults options,
				title: app.name
				icon: yes
				iconLink: null
				subtitle: ""

			if settings.icon is yes
				settings.icon = logo
			else if settings.icon is "small"
				settings.icon = logo
				settings.isSmallIcon = yes

			stManager.add @STMANAGER_DEPENDENCIES, ->
				WkView.show no, template( settings ),
					hide_title: 1
					wkRaw: options.pageName
					className: "wk_large_cont"
				, "", no

## `modal.showMessageBox`

		showMessageBox: ( options = {}) ->
			box = MessageBox options
			box.content options.content
			box.show()

## `modal.showProgressBar`

		showProgressBar: ( options = {}) ->
			options = _.defaults options,
				content: ""
				progress: 0

			box = MessageBox options

			progressBarHtml = progressBarTemplate options
			box.progress = options.progress
			box.content options.content + progressBarHtml

			box.setProgress = ( progress = 0 ) ->
				if progress > 100
					progress = 100
				el = @bodyNode.getElementsByClassName( "vkx-progress-bar-done" )[ 0 ]
				el.style.width = progress + "%"
				@progress = progress
				@

			box.show()

	module.exports = modal
