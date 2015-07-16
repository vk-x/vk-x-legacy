	app = require "./app"
	performRequest = require "./ajax/perform-request"
	ajax = require( "./ajax" ) app, performRequest
	vkApi = require( "./vk-api" ) app, ajax
	dislike = require( "./dislike" ) ajax, vkApi
	i18n = require( "./i18n" )()
	modal = require( "./modal" ) app
	install = require( "./install" ) app, i18n, modal
	mainMenu = require( "./main-menu" ) app
	_ = require "lodash"
	md5 = require "md5-jkmyers"

	i18n.addLanguage "ru", require "./i18n/ru"
	i18n.addLanguage "ua", require "./i18n/ua"
	i18n.addLanguage "by", require "./i18n/by"
	i18n.addLanguage "en", require "./i18n/en"
	i18n.addLanguage "it", require "./i18n/it"
	i18n.addLanguage "tat", require "./i18n/tat"

For compatibility with legacy code:

	# TODO: Migrate to "en" some day.
	i18n.setFallbackLanguage "ru"

	app.ajax = ajax
	app.vkApi = vkApi
	app.dislike = dislike
	app.i18n = i18n
	app.modal = modal
	app.install = install
	app.mainMenu = mainMenu
	app.util = _
	app.util.md5 = md5

	window.app = app
