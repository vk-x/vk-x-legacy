	module.exports = ( app, i18n ) ->
		changelogHtml: ->
			title = i18n.t "changelogTitle"
				.replace "{version}", app.version.full
				.replace "{name}", app.name

			subtitle = i18n.t "changelogSubtitle"
				.replace "{version}", app.version.full
				.replace "{name}", app.name

			body = i18n.t "changelogBody"

			homepageLink = app.homepage
			homepage = i18n.t "homepage"
				.replace "{name}", app.name

			fs = require "fs"
			logo = "data:image/png;base64," +
				fs.readFileSync "#{__dirname}/meta/logo.png", "base64"

			template = require "./install/changelog-template"

			template { title, subtitle, body, homepage, homepageLink, logo }
