	describe "mainMenu", ->

		mainMenu = require "../../source/main-menu"

		describe "extensionMenuItemHtml", ->

			it "should return html", ->
				mainMenu.extensionMenuItemHtml().should.be.a "string"
