	app = require "./app"
	modal = require "./modal"
	i18n = require "./i18n"

	module.exports =

		showChangelog: ->
			title = i18n.t "changelogTitle"
				.replace "{version}", app.version.full
				.replace "{name}", app.name

			subtitle = i18n.t "changelogSubtitle"
				.replace "{version}", app.version.full
				.replace "{name}", app.name

			content = i18n.t "changelogContent"
				.replace "{name}", app.name
				.replace "{homepage}", app.homepage

			modal.showPage
				title: title
				iconLink: app.homepage
				subtitle: subtitle
				content: content
				pageName: "changelog"

			@newVersionFlag off

		newVersionFlag: ( value ) ->
			if value is on
				localStorage[ app.name + "-new-version" ] = on
			else if value is off
				localStorage.removeItem app.name + "-new-version"
			else
				localStorage[ app.name + "-new-version" ]?
