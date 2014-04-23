	describe "install", ->

		app = require "../../source/app"
		i18n = require( "../../source/i18n" )()
		installFactory = require "../../source/install"
		install = null
		beforeEach -> install = installFactory app, i18n

		describe "changelogHtml", ->

			it "should return html", ->
				sinon.stub i18n, "t", ( name ) -> name
				install.changelogHtml().should.be.a "string"
