[tests]: ../test/unit/i18n.litcoffee

**Note**: see [tests][tests] for API documentation.
This file only contains notes on internal details.

# `i18n` module

	_ = require "lodash"

	i18n = ->

		_languages: {}
		_currentName: null
		_fallbackLanguage: null


## `i18n.addLanguage`

		addLanguage: ( name, translations ) ->
			if @_languages[ name ]
				throw Error "Language \"#{name}\" already exists!"

			@_languages[ name ] = translations

## `i18n.setLanguage`

		setLanguage: ( name ) ->
			if not @_languages[ name ]
				throw Error "Cannot set unknown language \"#{name}\"!"

			@_currentName = name

## `i18n.detectLanguage`

		_codeToLanguageName:
			0: "ru"
			1: "ua"
			3: "en"
			7: "it"
			50: "tat"
			114: "by"

		detectLanguage: ( code ) ->
			@setLanguage @_codeToLanguageName[ code ] ? "ru"

## `i18n.setFallbackLanguage`

		setFallbackLanguage: ( name ) ->
			if not @_languages[ name ]
				throw Error "Cannot set unknown language \"#{name}\"!"

			@_fallbackLanguage = name

## `i18n.t`

		t: ( key ) ->
			if not @_currentName
				throw Error "Current language is not set!"

			@_languages[ @_currentName ][ key ] ?
			@_languages[ @_fallbackLanguage ]?[ key ] ?
			throw Error "No translation is available for \"#{key}\"!
			Current language is \"#{@_currentName}\", fallback language is
			\"#{@_fallbackLanguage}\"."

## `i18n.IDL`

		IDL: ( key, bracketsFlag ) ->
			translation = @.t key

			return translation if _.isArray translation

			translation = translation.trim()

			WRAP_WITH_BRACKETS = 1
			TRIM_BRACKETS = 2

			isTrimBracketsEnabled = bracketsFlag is TRIM_BRACKETS or
				window.CUT_VKOPT_BRACKET is on

			if bracketsFlag is WRAP_WITH_BRACKETS
				"[ #{translation} ]"
			else if isTrimBracketsEnabled and translation[ 0 ] is "["
				translation
					.substring 1, translation.length - 1
					.trim()
			else
				translation

	module.exports = i18n
