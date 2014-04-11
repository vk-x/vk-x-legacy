# `app` module

This is the base module with meta project information.

	describe "app", ->
		app = null
		beforeEach -> app = require "../../source/app"

		it "should have correct metadata", ->
			app.name.should.equal "<%= name %>"
			app.version.should.deep.equal
				full: "<%= version %>"
				major: <%= version.split( "." )[ 0 ] %>
				minor: <%= version.split( "." )[ 1 ] %>
				patch: <%= version.split( "." )[ 2 ] %>
			app.homepage.should.equal "<%= homepage %>"
