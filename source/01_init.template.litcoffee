	app =
		name: "<%= name %>"
		version:
			full: "<%= version %>"
			major: <%= version.split( "." )[ 0 ] %>
			minor: <%= version.split( "." )[ 1 ] %>
			patch: <%= version.split( "." )[ 2 ] %>
		homepage: "<%= homepage %>"

	<%= name %> = app

	app.util = _.noConflict()
	app.util.uri = URI.noConflict()
