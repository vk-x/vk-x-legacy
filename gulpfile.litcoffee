# Table of contents

<!-- MarkdownTOC depth=4 autolink=true bracket=round -->

- [Dev documentation](#dev-documentation)
	- [TL;DR](#tldr)
	- [Tech stack](#tech-stack)
	- [Get the code](#get-the-code)
	- [Prepare environment](#prepare-environment)
	- [Build unpacked extensions](#build-unpacked-extensions)
	- [Install an unpacked extension](#install-an-unpacked-extension)
		- [Chromium](#chromium)
		- [Firefox](#firefox)
		- [Opera 12](#opera-12)
		- [Maxthon](#maxthon)
	- [Run tests](#run-tests)
	- [Build extensions](#build-extensions)
	- [Test and build continuously](#test-and-build-continuously)
- [Tasks specification](#tasks-specification)
	- [Loading dependencies](#loading-dependencies)
	- [`test`](#test)
	- [`clean-build` and `clean-dist`](#clean-build-and-clean-dist)
	- [`meta`](#meta)
	- [`scripts`](#scripts)
	- [`dist-maxthon`](#dist-maxthon)
	- [`dist-zip`](#dist-zip)
	- [Shortcuts](#shortcuts)

<!-- /MarkdownTOC -->

# Dev documentation

## TL;DR
vk-x is written in CoffeeScript, built using Browserify, tested in PhantomJS
using Karma.

- `npm i` to prepare the environment
- `gulp test` to run tests
- `gulp build` to build unpacked extensions
- `gulp dist` to build packed extensions
- `gulp` to watch for changes and automatically run `gulp test` and `gulp build`

## Tech stack
We use [Literate CoffeeScript](http://coffeescript.org/#literate) for the code,
[Jade](http://jade-lang.com/) for templates,
[Stylus](http://learnboost.github.io/stylus/) for styles.

Scripts are assembled using [Browserify](http://browserify.org/).
See [`scripts` task](#scripts) defined below and
[browserify config](build/browserify-config.litcoffee) for gore details.  
Templates, styles and [even images](build/base64-transform.litcoffee) are
inlined using transforms.

Tests are run by [Karma](http://karma-runner.github.io/)
in [PhantomJS](http://phantomjs.org/).
See [`test/karma-config.litcoffee`](test/karma-config.litcoffee) file
for docs on tests.

[gulp](https://github.com/gulpjs/gulp) is our build automation tool.

There's a bunch of JavaScript files in
[`source/legacy`](source/legacy) - that's the VkOpt code. We're rewriting it.

## Get the code
- If you are new to Git, see
[Set Up Git](https://help.github.com/articles/set-up-git).
- Sign up for [GitHub](https://github.com/).
- Fork the project repo and clone it locally.
See [Fork A Repo](https://help.github.com/articles/fork-a-repo).

## Prepare environment
- Install [NodeJS](http://nodejs.org/).
- Install [gulp](http://gulpjs.com) command line utility:
`npm install -g gulp`
- Install dependencies: `npm install`

See [`package.json`](package.json) for a full list of dependencies.

**Note**: run these commands inside the project directory.

## Build unpacked extensions
`gulp build`

See the [`build` task](#shortcuts) defined below.

## Install an unpacked extension

#### Chromium
Manual: https://developer.chrome.com/extensions/getstarted#unpacked  
Path to unpacked extension: `./build/chromium` (relative to project folder).

How to reload extension using a button or hotkey:
http://stackoverflow.com/q/2963260

#### Firefox
Manual: http://stackoverflow.com/q/15908094  
Path to unpacked extension: `./build/firefox` (relative to project folder).  
Extension ID: see `<em:id>` element in `./build/firefox/install.rdf`.

#### Opera 12
Manual:
- Open Opera, go to extensions page (press `Ctrl + Shift + E`).
- Drag'n'drop `./build/opera/config.xml` on the
Opera extensions page.

#### Maxthon
No idea. :(

## Run tests
`gulp test`

See the [`test` task](#test) defined below.

## Build extensions
`gulp dist`

See the [`dist` task](#shortcuts) defined below.

## Test and build continuously
If you want to rerun tests and rebuild unpacked extensions on
changes simply run: `gulp`.

Then go change some code and see it rebuilding automatically.

See the [`default` task](#shortcuts) defined below.

# Tasks specification

#### Loading dependencies
See: https://github.com/gulpjs/gulp/blob/master/README.md#sample-gulpfile

	gulp = require "gulp"
	_ = require "lodash"
	es = require "event-stream"
	path = require "path"
	fs = require "fs-extra"
	colors = require "colors"
	config = require "./package"
	plugins = ( require "gulp-load-plugins" )()
	cwd = process.cwd()
	browserify = require "browserify"
	buffer = require "vinyl-buffer"
	source = require "vinyl-source-stream"
	globby = require "globby"
	distPrefix = "#{config.name}-#{config.version}"
	browserifyConfig = ( require "./build/browserify-config" ) "build"

	getBrowserifyStream = ( globs, cwd, buildType, callback ) ->
		globby globs, cwd: cwd, ( err, entries ) ->
			streams = entries.map ( entry ) ->
				b = browserify ( require "./build/browserify-config" ) buildType
				b.add path.join cwd, entry
				b.bundle()
					.pipe source entry
					.pipe buffer()

			callback es.concat streams

#### `test`
See [`test/karma-config.litcoffee`](test/karma-config.litcoffee) file
for docs on tests.

	gulp.task "browserify-test", ( done ) ->
		getBrowserifyStream [ "**/*.litcoffee" ], "./test/unit", "test", ( stream ) ->
			stream
				.pipe gulp.dest "./test/bundle/"
				.on "end", done

	gulp.task "test", [ "browserify-test" ], ( done ) ->
		karma = require "karma"
		server = new karma.Server
			configFile: "#{__dirname}/test/karma-config.litcoffee"
		, done

		server.start()

#### `clean-build` and `clean-dist`

	removeFolder = ( folder, callback ) ->
		busyFiles = []
		retryInterval = 50
		tryRemove = ->
			fs.remove folder, ( error ) ->
				if error
					if error.path not in busyFiles
						busyFiles.push error.path
						relativePath = path.relative cwd, error.path
						errorMessage = "Can't remove #{relativePath}, " +
						"will retry each #{retryInterval}ms until success."
						console.log errorMessage.yellow
					setTimeout tryRemove, retryInterval
				else callback()
		tryRemove()

	gulp.task "clean-dist", ( done ) ->
		removeFolder "dist", done

	for folder in [ "chromium", "firefox", "maxthon", "opera" ]
		do ( folder ) ->
			gulp.task "clean-#{folder}", ( done ) ->
				removeFolder "build/#{folder}", done

	gulp.task "clean-build", [
		"clean-chromium"
		"clean-firefox"
		"clean-maxthon"
		"clean-opera"
	]

#### `meta`

	gulp.task "meta", [ "clean-build" ], ->
		noticeTemplate = fs.readFileSync "./source/meta/notice.template.js"

		metaStream = gulp.src "source/meta/*/**/*"
			.pipe plugins.filter [ "**/*", "!**/*.ignore.*" ]
			.pipe plugins.filter [ "**/*", "!**/*.{js,litcoffee}" ]
			.pipe plugins.if /\.template\./, plugins.template config
			.pipe plugins.if /\.template\./, plugins.rename ( path ) ->
				path.basename = path.basename.replace /\.template$/, ""
				return
			.pipe plugins.if /\.js$/, plugins.header noticeTemplate, config
			.pipe gulp.dest "build"

		licenseStream = gulp.src "LICENSE.md"
			.pipe gulp.dest "build/chromium"
			.pipe gulp.dest "build/firefox"
			.pipe gulp.dest "build/maxthon"
			.pipe gulp.dest "build/opera"

		es.concat metaStream, licenseStream

#### `scripts`

	getSourceForTopStream = ( callback ) ->
		getBrowserifyStream [ "index-top.litcoffee" ], "./source", "build", ( stream ) ->
			browserifyStream = stream
				.pipe plugins.rename "bundle.js"

			legacyStream = gulp.src "source/legacy/*.js"
				.pipe plugins.concat "legacy.js"

			resultStream = es.concat browserifyStream, legacyStream
				.pipe plugins.order [ "bundle.js", "legacy.js" ]
				.pipe plugins.concat "run-in-top.js"

			callback resultStream

	getSourceForFramesStream = ( callback ) ->
		getBrowserifyStream [ "index-frames.litcoffee" ], "./source", "build", ( stream ) ->
			callback stream.pipe plugins.rename "run-in-frames.js"

	injectSourceForTop = ( stream ) ->
		plugins.inject stream,
			starttag: "sourceForTop = \""
			endtag: "\""
			transform: ( path, file ) ->
				escapeString = require "js-string-escape"
				escapeString file.contents

	injectSourceForFrames = ( stream ) ->
		plugins.inject stream,
			starttag: "sourceForFrames = \""
			endtag: "\""
			transform: ( path, file ) ->
				escapeString = require "js-string-escape"
				escapeString file.contents

	userscriptHeader = -> fs.readFileSync "./source/meta/opera/userscript-header.js"
	noticeTemplate = -> fs.readFileSync "./source/meta/notice.template.js"

	gulp.task "scripts", [ "clean-build" ], ( done ) ->
		getSourceForTopStream ( sourceForTopStream ) ->
			getSourceForFramesStream ( sourceForFramesStream ) ->
				getBrowserifyStream [
					"**/content.litcoffee"
					"**/background.litcoffee"
				], "./source/meta", "build", ( stream ) ->
					contentScriptStream = stream
						.pipe plugins.rename extname: ".js"
						.pipe plugins.header noticeTemplate(), config
						.pipe injectSourceForTop sourceForTopStream
						.pipe injectSourceForFrames sourceForFramesStream
						.pipe plugins.if /opera/, plugins.header userscriptHeader()
						.pipe gulp.dest "build"

					distStream = es.concat sourceForTopStream, sourceForFramesStream
						.pipe plugins.header noticeTemplate(), config
						.pipe gulp.dest "build/chromium"
						.pipe gulp.dest "build/firefox/scripts"

					es.concat contentScriptStream, distStream
						.on "end", done

#### `dist-maxthon`
Distributable Maxthon extension created using
[`build/maxthon-packager.exe`](build)
([Extension/Skin Package Tool](http://forum.maxthon.com/thread-801-1-1.html)).

	gulp.task "dist-maxthon", [ "meta", "scripts", "clean-dist" ], ( done ) ->
		isWindows = ( require "os" ).type() is "Windows_NT"
		unless isWindows
			console.log ( "Maxthon packager only guaranteed " +
				"to work on Windows. Trying anyway..." ).yellow

		{ execFile } = require "child_process"
		resultName = "#{distPrefix}-maxthon.mxaddon"
		pathToResult = path.join cwd, "dist", resultName
		pathToSource = path.join cwd, "build", "maxthon"
		pathToBuilder = path.join cwd, "build", "maxthon-packer.exe"

		try
			execFile pathToBuilder, [ pathToSource, pathToResult ], null,
				( error ) ->
					if error
						console.log "Maxthon packager exitted with error:".yellow,
							error
					else unless isWindows
						console.log ( "Looks like Maxthon packager finished " +
							"successfully." ).green
					done()
		catch error
			console.log "Maxthon packager exitted with error:".yellow, error
			done()

#### `dist-zip`
Distributable extensions created using ZIP archivation.

	gulp.task "dist-zip", [ "meta", "scripts", "clean-dist" ], ->

**Firefox** allows to install add-ons from `.xpi` packages
(which are simply zip archives), you might want one.

		firefoxStream = gulp.src "**/*.*",
				cwd: path.join cwd, "build", "firefox"
			.pipe plugins.zip "#{distPrefix}-firefox.xpi"

**Chromium** (particularly Google Chrome) uses `.crx`
which are hard to create.  
You might need a `.zip` with unpacked extension though to upload to
Chrome Web Store or just because it is easier to send.

		chromiumStream = gulp.src "**/*.*",
				cwd: path.join cwd, "build", "chromium"
			.pipe plugins.zip "#{distPrefix}-chromium.zip"

**Opera** allows to install extensions from `.oex` packages
(which are simply zip archives), you might want one.

		operaStream = gulp.src "**/*.*",
				cwd: path.join cwd, "build", "opera"
			.pipe plugins.zip "#{distPrefix}-opera.oex"

		es.concat firefoxStream, chromiumStream, operaStream
			.pipe gulp.dest "dist"

#### Shortcuts

	gulp.task "dist", [ "dist-maxthon", "dist-zip" ]

	gulp.task "build", [ "meta", "scripts" ]

	gulp.task "default", [ "build", "test" ], ->
		gulp.watch [ "source/**/*.*", "test/**/*.*" ], [ "build", "test" ]
