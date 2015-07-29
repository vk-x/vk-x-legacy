# `modal` module

	describe "modal", ->

		modal = require "../../source/modal"

## What?

**`modal`** module allows to open modal popups:

![](http://i.imgur.com/AnkCuPP.png)

## Why?

At least extension settings and changelog are opened as modals, so we should
separate this functionality.

## How?

#### API

```CoffeeScript
modal = require "./modal"

modal.showPage
	title: "Hello, world!" # optional, app.name is default
	icon: yes # yes | no | "small", optional, yes is default
	iconLink: "/id1" # <a> which contains icon will have this as href, optional
	subtitle: "Smaller second title" # optional, "" is default
	content: "..."
	pageName: "example" # Used in url: /current/page#example

modal.showMessageBox
	# All options are optional.
	# See `window.MessageBox` on vk.com for more options.
	title: "foo"
	content: "<strong>bar</strong>"
	dark: yes
	width: 650
```

#### Use existing vk wiki-style modals functionality.

Let's use existing vk code used to show posts, pages etc.  
It is namespaced under `window.WkView` which comes from `wkview.js` and `wk.js`.
We can use vk's `stManager` to include them and the css.

## Module meta info

		it "should have STMANAGER_DEPENDENCIES", ->
			modal.STMANAGER_DEPENDENCIES.should.be.an "array"

## `modal.showPage`

		describe "showPage", ->

			it "should call stManager.add() and then WkView.show()", ( done ) ->
				window.stManager = add: ( dependencies, callback ) ->
					window.stManager = null
					dependencies.should.deep.equal modal.STMANAGER_DEPENDENCIES
					window.WkView = show: ( title, html,
					options, script, ev ) ->
						window.WkView = null
						title.should.equal no
						html.should.contain "fake-content"
						html.should.contain "fake-title"
						html.should.contain "fake-subtitle"
						html.should.contain "/id1"
						options.should.deep.equal
							hide_title: 1
							wkRaw: "fake-pageName"
							className: "wk_large_cont"
					callback()
					done()

				modal.showPage
					title: "fake-title"
					icon: yes
					iconLink: "/id1"
					subtitle: "fake-subtitle"
					content: "fake-content"
					pageName: "fake-pageName"

			it "should throw when no content specified", ->
				( -> modal.showPage
					title: "fake-title"
					icon: yes
					iconLink: "/id1"
					subtitle: "fake-subtitle"
					pageName: "fake-pageName" ).should.throw "Modal content
					not specified!"

			it "should throw when no page name specified", ->
				( -> modal.showPage
					title: "fake-title"
					icon: yes
					iconLink: "/id1"
					subtitle: "fake-subtitle"
					content: "fake-content" ).should.throw "Modal page name
					not specified!"

			it "should have sane defaults", ( done ) ->
				window.stManager = add: ( dependencies, callback ) ->
					window.stManager = null
					dependencies.should.deep.equal modal.STMANAGER_DEPENDENCIES
					window.WkView = show: ( title, html,
					options, script, ev ) ->
						window.WkView = null
						title.should.equal no
						# TODO: Move logic to private method to make it
						# more testable (e.g. is `subtitle` really `""` here?).
						html.should.contain "fake-content"
						options.should.deep.equal
							hide_title: 1
							wkRaw: "fake-pageName"
							className: "wk_large_cont"
					callback()
					done()

				modal.showPage
					content: "fake-content"
					pageName: "fake-pageName"

## `modal.showMessageBox`

		describe "showMessageBox", ->

			it "should use vk's MessageBox()", ->

				# A workaround for sinon.wrapMethod()
				# See https://github.com/cjohansen/Sinon.JS/pull/449
				window.MessageBox ?= ->

				sinon.stub window, "MessageBox", ( options ) ->
					options.should.contain
						foo: "bar"

					box =
						content: ( content ) ->
							content.should.equal "whatever"
							@
						show: ->
							@

					sinon.spy box, "content"
					sinon.spy box, "show"

					box

				box = modal.showMessageBox
					foo: "bar"
					content: "whatever"

				MessageBox.should.have.been.calledOnce
				box.content.should.have.been.calledOnce
				box.show.should.have.been.calledOnce

				MessageBox.restore()
