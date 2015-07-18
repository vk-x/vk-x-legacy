# `i18n` module

	describe "i18n", ->

		i18n = require "../../source/i18n"

		beforeEach ->
			i18n._languages = {}
			i18n._currentName = null
			i18n._fallbackLanguage = null

## What?

**`i18n`** module provides interface for **internationalization**.
It provides interface for common i18n and t10n tasks.

## Why?

Because **VK** itself is international.

## How?

#### API

```CoffeeScript
i18n = require "./i18n"

i18n.addLanguage "en",
	hello: "Hello, world!"
	...

i18n.addLanguage "ru", ...
i18n.addLanguage "uk", ...

i18n.setLanguage "ru"
# or
i18n.detectLanguage window.vk.lang

# Use English for strings unavailable in current language.
i18n.setFallbackLanguage "en"

# Get "hello" string in Russian.
translated = i18n.t "hello"
```

There's also a deprecated `IDL` method for backward compatibility
with legacy code. **Do not use this method.**

```
# Suppose translation for "someKey" is "audio".
# This will return "[ audio ]":
translated = i18n.IDL "someKey", 1

# Suppose translation for "someKey" is "[ audio ]".
# This will return "audio":
translated = i18n.IDL "someKey", 2
```

## `i18n.addLanguage`

		describe "addLanguage", ->

			it "should add a language to _languages", ->
				i18n.addLanguage "fake", hello: "world!"
				
				i18n._languages.should.deep.equal fake: hello: "world!"

			it "should throw if the language has been already added", ->
				i18n.addLanguage "fake", hello: "world!"
				( -> i18n.addLanguage "fake", already: "added" )
					.should.throw "Language \"fake\" already exists!"

## `i18n.setLanguage`

		describe "setLanguage", ->

			it "should set _currentName", ->
				i18n.addLanguage "fake", hello: "world!"
				expect( i18n._currentName ).to.equal null
				i18n.setLanguage "fake"
				i18n._currentName.should.equal "fake"

			it "should throw if language doesn't exist", ->
				( -> i18n.setLanguage "fake" )
					.should.throw "Cannot set unknown language \"fake\"!"
				expect( i18n._currentName ).to.equal null

## `i18n.detectLanguage`

		it "should have _codeToLanguageName", ->
			i18n._codeToLanguageName.should.be.an "object"

		describe "detectLanguage", ->

			it "should convert code to language name and set that
			language", ->
				for code, name of i18n._codeToLanguageName
					sinon.stub i18n, "setLanguage", ( passedName ) ->
						passedName.should.equal name

					i18n.detectLanguage code

					i18n.setLanguage.should.have.been.calledOnce
					i18n.setLanguage.restore()

			it "should default to \"ru\" if code is unknown", ->
				i18n.addLanguage "ru", hello: "world!"
				i18n.detectLanguage "lol wtf this is not even an integer"
				i18n._currentName.should.equal "ru"

## `i18n.setFallbackLanguage`

		describe "setFallbackLanguage", ->

			it "should set _fallbackLanguage", ->
				i18n.addLanguage "fake", hello: "world!"
				expect( i18n._fallbackLanguage ).to.equal null
				i18n.setFallbackLanguage "fake"
				i18n._fallbackLanguage.should.equal "fake"

			it "should throw if language doesn't exist", ->
				( -> i18n.setFallbackLanguage "fake" )
					.should.throw "Cannot set unknown language \"fake\"!"
				expect( i18n._fallbackLanguage ).to.equal null

## `i18n.t`

		describe "t", ->

			it "should return translated string by key", ->
				i18n.addLanguage "fake", hello: "world!"
				i18n.setLanguage "fake"
				i18n.t( "hello" ).should.equal "world!"

			it "should return string in default language if unavailable
			in current language", ->
				i18n.addLanguage "fake-fallback", onlyInFallback: "ok"
				i18n.setFallbackLanguage "fake-fallback"
				i18n.addLanguage "fake-current", otherKey: "not ok"
				i18n.setLanguage "fake-current"

				i18n.t( "onlyInFallback" ).should.equal "ok"

			it "should return array if the translation is an array", ->
				i18n.addLanguage "fake", hello: [ "world", "!" ]
				i18n.setLanguage "fake"
				i18n.t( "hello" ).should.deep.equal [ "world", "!" ]

			it "should return array if the translation is an array in
			fallback language", ->
				i18n.addLanguage "fake-fallback", onlyInFallback: [ "ok" ]
				i18n.setFallbackLanguage "fake-fallback"
				i18n.addLanguage "fake-current", otherKey: "not ok"
				i18n.setLanguage "fake-current"
				i18n.t( "onlyInFallback" ).should.deep.equal [ "ok" ]

			it "should throw if current language is not set", ->
				i18n.addLanguage "fake", hello: "world!"

				( -> i18n.t "hello" ).should.throw "Current language
				is not set!"

			it "should throw if no translation in current and fallback
			languages", ->
				i18n.addLanguage "fake-fallback", hello: "fallback"
				i18n.setFallbackLanguage "fake-fallback"
				i18n.addLanguage "fake-current", hello: "current"
				i18n.setLanguage "fake-current"

				( -> i18n.t "dunno" ).should.throw "No translation is
				available for \"dunno\"!"

			it "should throw if no translation in current language, and
			fallback language is not set", ->
				i18n.addLanguage "fake-current", hello: "world!"
				i18n.setLanguage "fake-current"

				( -> i18n.t "dunno" ).should.throw "No translation is
				available for \"dunno\"!"

## `i18n.IDL`

		describe "IDL", ->

			it "should just return translated string if bracketsFlag
			is undefined", ->
				i18n.addLanguage "fake", hello: "world!"
				i18n.setLanguage "fake"
				i18n.IDL( "hello" ).should.equal i18n.t "hello"

			it "should remove --force square brackets
			if bracketsFlag is 2", ->
				i18n.addLanguage "fake", hello: "[world!]"
				i18n.setLanguage "fake"
				i18n.IDL( "hello", 2 ).should.equal "world!"

			it "should just return translated string if bracketsFlag
			is 2 and string is not in brackets", ->
				i18n.addLanguage "fake", hello: "world!"
				i18n.setLanguage "fake"
				i18n.IDL( "hello", 2 ).should.equal "world!"

			it "should remove --force spaces and square brackets
			if bracketsFlag is 2", ->
				i18n.addLanguage "fake", hello: "  [world!  ] "
				i18n.setLanguage "fake"
				i18n.IDL( "hello", 2 ).should.equal "world!"

			it "should remove --force square brackets
			if window.CUT_VKOPT_BRACKET is on", ->
				i18n.addLanguage "fake", hello: "[world!]"
				i18n.setLanguage "fake"
				window.CUT_VKOPT_BRACKET = on
				i18n.IDL( "hello" ).should.equal "world!"
				window.CUT_VKOPT_BRACKET = undefined

			it "should remove --force square brackets
			if window.CUT_VKOPT_BRACKET is on", ->
				i18n.addLanguage "fake", hello: "  [world!  ] "
				i18n.setLanguage "fake"
				window.CUT_VKOPT_BRACKET = on
				i18n.IDL( "hello" ).should.equal "world!"
				window.CUT_VKOPT_BRACKET = undefined

			it "should wrap with square brackets
			if bracketsFlag is 1", ->
				i18n.addLanguage "fake", hello: " world!  "
				i18n.setLanguage "fake"
				i18n.IDL( "hello", 1 ).should.equal "[ world! ]"

			it "should return array if the translation is an array", ->
				i18n.addLanguage "fake", hello: [ "world", "!" ]
				i18n.setLanguage "fake"
				i18n.IDL( "hello" ).should.deep.equal [ "world", "!" ]

			it "should return array if the translation is an array,
			when bracketsFlag is set to 1", ->
				i18n.addLanguage "fake", hello: [ "world", "!" ]
				i18n.setLanguage "fake"
				i18n.IDL( "hello", 1 ).should.deep.equal [ "world", "!" ]

			it "should return array if the translation is an array,
			when bracketsFlag is set to 2", ->
				i18n.addLanguage "fake", hello: [ "world", "!" ]
				i18n.setLanguage "fake"
				i18n.IDL( "hello", 2 ).should.deep.equal [ "world", "!" ]
