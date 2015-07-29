	describe "install", ->

		install = require "../../source/install"

		app = require "../../source/app"
		modal = require "../../source/modal"
		i18n = require "../../source/i18n"
		
		describe "showChangelog", ->

			it "should correctly call modal.showPage()", ( done ) ->
				sinon.stub i18n, "t", ( name ) -> name
				sinon.stub modal, "showPage", ( settings ) ->
					modal.showPage.restore()
					settings.title.should.equal "changelogTitle"
					settings.iconLink.should.equal app.homepage
					settings.subtitle.should.equal "changelogSubtitle"
					settings.content.should.equal "changelogContent"
					settings.pageName.should.equal "changelog"
					done()

				install.showChangelog()

		describe "newVersionFlag", ->

			it "should set localStorage flag to `on` when value is `on`", ->
				localStorage[ app.name + "-new-version" ] = off
				install.newVersionFlag on
				# localStorage stringifies `on` (`true` in compiled js).
				localStorage[ app.name + "-new-version" ].should.equal "true"

			it "should remove localStorage flag when value is `off`", ->
				localStorage[ app.name + "-new-version" ] = on
				install.newVersionFlag off
				localStorage.should.not.have.key app.name + "-new-version"

			it "should return localStorage flag? when no value", ->
				localStorage[ app.name + "-new-version" ] = on
				install.newVersionFlag().should.equal on
				localStorage.removeItem app.name + "-new-version"
				install.newVersionFlag().should.equal off
