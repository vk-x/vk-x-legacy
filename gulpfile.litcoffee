# Dev documentation

## Build status

master | develop
:----: | :-----:
[![Build Status](https://travis-ci.org/deltaidea/happy.png?branch=master)](https://travis-ci.org/deltaidea/happy) | [![Develop](https://travis-ci.org/deltaidea/happy.png?branch=develop)](https://travis-ci.org/deltaidea/happy)

We have **[Travis CI](https://travis-ci.org/deltaidea/happy)** running
`gulp test && gulp dist` on each push and Pull Request.  
See **Prepare environment**, **Run tests** and **Build extensions**
below for more info.

## Tech stack

We use [CoffeeScript](http://coffeescript.org) language.

## Fork the repo

- If you are new to Git see: https://help.github.com/articles/set-up-git
- Sign up for [Github](https://github.com/).
- Fork the project repo. See: https://help.github.com/articles/fork-a-repo

## Prepare environment

We use [gulp](http://gulpjs.com) to build extensions and
[Karma](http://karma-runner.github.io/) to run tests.  
See `package.json` for a full list of dependencies.

- Install [NodeJS](http://nodejs.org/).
- Install [gulp](http://gulpjs.com) command line utility:
`$ npm install -g gulp`
- Install dev dependencies: `$ npm install`
- Install source dependencies: `$ gulp bower`

**Note**: run all these commands inside project directory.

## Build unpacked extensions
To build unpacked extensions open command line and type: `$ gulp build`.

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
To run unit tests open command line and type: `$ gulp test`.

## Build extensions
To build packed extensions open command line and type: `$ gulp dist`.

## Test and build continuously
If you want to rerun tests and rebuild unpacked extensions on
changes simply run: `$ gulp`.

Then go change some code and see it rebuilding automatically.

# Tasks specification

#### gulpfile.js
[gulp](http://gulpjs.com) uses `gulpfile.js` as a place
for tasks specification.  
It doesn't support CoffeeScript out-of-the-box,
so we use `gulpfile.js` to load runtime CoffeeScript compiler and then load
this `gulpfile.litcoffee` file.

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
	distPrefix = "#{config.name}-#{config.version}"
	browserifyConfig = require "./build/browserify-config"

#### bower

	bowerBackgroundDeps =
		"superagent": "bower_components/superagent/superagent.js"

	gulp.task "bower", ->
		bower = require "bower"
		bower.commands.install _.keys bowerBackgroundDeps

#### test
See `test/karma-config.litcoffee` file for docs on tests.

	gulp.task "test", ->
		gulp.src [ "./test/unit/index.litcoffee" ]
			.pipe plugins.karma
				configFile: "test/karma-config.litcoffee"

#### clean-build and clean-dist

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

#### meta

	gulp.task "meta", [ "clean-build" ], ->
		noticeTemplate = fs.readFileSync "./source/meta/notice.template.js"
		
		metaStream = gulp.src "source/meta/*/**/*"
			.pipe plugins.filter "!**/*.ignore.*"
			.pipe plugins.filter "!**/*.litcoffee"
			.pipe plugins.if /\.template\./, plugins.template config
			.pipe plugins.if /\.template\./, plugins.rename ( path ) ->
				path.basename = path.basename.replace /\.template$/, ""
				return
			.pipe plugins.if /\.js$/, plugins.header noticeTemplate, config
			.pipe gulp.dest "build"

		bowerBackgroundDepsStream = gulp.src _.values bowerBackgroundDeps
			.pipe plugins.concat "helpers.js"
			.pipe gulp.dest "build/chromium"
			.pipe gulp.dest "build/firefox/chrome/content"
			.pipe gulp.dest "build/maxthon"
			.pipe gulp.dest "build/opera"

		licenseStream = gulp.src "LICENSE.md"
			.pipe gulp.dest "build/chromium"
			.pipe gulp.dest "build/firefox"
			.pipe gulp.dest "build/maxthon"
			.pipe gulp.dest "build/opera"

		es.concat metaStream, licenseStream, bowerBackgroundDepsStream

#### scripts

	gulp.task "scripts", [ "clean-build" ], ->
		sourceForTopStream = ->
			legacyStream =
				gulp.src "source/legacy/*.js"
					.pipe plugins.concat "legacy.js"

			browserifyStream = gulp.src "source/index-top.litcoffee", read: no
				.pipe plugins.browserify browserifyConfig
				.pipe plugins.rename "bundle.js"

			es.concat browserifyStream, legacyStream
				.pipe plugins.order [ "bundle.js", "legacy.js" ]
				.pipe plugins.concat "run-in-top.js"

		sourceForFramesStream = ->
			gulp.src "source/index-frames.litcoffee", read: no
				.pipe plugins.browserify browserifyConfig
				.pipe plugins.rename "run-in-frames.js"

		injectSourceForTop = plugins.inject sourceForTopStream(),
			starttag: "sourceForTop = \""
			endtag: "\""
			transform: ( path, file ) ->
				escapeString = require "js-string-escape"
				escapeString file.contents

		injectSourceForFrames = plugins.inject sourceForFramesStream(),
			starttag: "sourceForFrames = \""
			endtag: "\""
			transform: ( path, file ) ->
				escapeString = require "js-string-escape"
				escapeString file.contents

		userscriptHeader = fs.readFileSync "./source/meta/opera/" +
			"userscript-header.js"
		noticeTemplate = fs.readFileSync "./source/meta/notice.template.js"

		contentScriptStream =
			gulp.src [
				"source/meta/*/**/content.litcoffee"
				"source/meta/*/**/background.litcoffee"
			], read: no
				.pipe plugins.browserify browserifyConfig
				.pipe plugins.rename extname: ".js"
				.pipe plugins.header noticeTemplate, config
				.pipe injectSourceForTop
				.pipe injectSourceForFrames
				.pipe plugins.if /opera/, plugins.header userscriptHeader
				.pipe gulp.dest "build"

		distStream = es.concat sourceForTopStream(), sourceForFramesStream()
			.pipe plugins.header noticeTemplate, config
			.pipe gulp.dest "build/chromium"
			.pipe gulp.dest "build/firefox/scripts"

		es.concat contentScriptStream, distStream

#### dist-maxthon
Distributable Maxthon extension created using `maxthon-packager.exe`
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
		pathToBuilder = path.join cwd, "maxthon-packager.exe"

		execFile pathToBuilder, [ pathToSource, pathToResult ], null,
			( error ) ->
				if error
					console.log "Maxthon packager exitted with error:".yellow,
						error
				else unless isWindows
					console.log ( "Looks like Maxthon packager finished " +
						"successfully." ).green
				done()

#### dist-zip
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
