	describe "mainMenu", ->

		app = require "../../source/app"
		mainMenuFactory = require "../../source/main-menu"
		mainMenu = null
		beforeEach -> mainMenu = mainMenuFactory app

		describe "extensionMenuItemHtml", ->

			it "should return html", ->
				mainMenu.extensionMenuItemHtml().should.be.a "string"
