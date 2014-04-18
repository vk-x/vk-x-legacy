	app = require "./app"
	performRequest = require( "./ajax/perform-request" ) app
	ajax = require( "./ajax" ) app, performRequest
	vkApi = require( "./vk-api" ) app, ajax
	dislike = require( "./dislike" ) ajax, vkApi
	i18n = require( "./i18n" )()
	_ = require "lodash"

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
	app.util = _

	window.app = app
