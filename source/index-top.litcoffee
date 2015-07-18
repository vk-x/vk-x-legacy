	app = require "./app"

For compatibility with legacy code:

	app.ajax = require "./ajax"
	app.dislike = require "./dislike"
	app.i18n = require "./i18n"
	app.install = require "./install"
	app.mainMenu = require "./main-menu"
	app.modal = require "./modal"
	app.util = require "lodash"
	app.util.md5 = require "md5-jkmyers"
	app.vkApi = require "./vk-api"

	app.i18n.addLanguage "ru", require "./i18n/ru"
	app.i18n.addLanguage "ua", require "./i18n/ua"
	app.i18n.addLanguage "by", require "./i18n/by"
	app.i18n.addLanguage "en", require "./i18n/en"
	app.i18n.addLanguage "it", require "./i18n/it"
	app.i18n.addLanguage "tat", require "./i18n/tat"

	# TODO: Migrate to "en" some day.
	app.i18n.setFallbackLanguage "ru"
	
	window.app = app
