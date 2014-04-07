	app = require "./app"
	performRequest = require( "./ajax/perform-request" ) app
	ajax = require( "./ajax" ) app, performRequest
	vkApi = require( "./vk-api" ) app, ajax
	dislike = require( "./dislike" ) ajax, vkApi
	_ = require "lodash"

For compatibility with legacy code:

	app.ajax = ajax
	app.vkApi = vkApi
	app.dislike = dislike
	app.util = _

	window.app = app
