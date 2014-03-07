# Dev documentation

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

#### bower

	bowerDeps =
		"lodash": "bower_components/lodash/dist/lodash.min.js"
		"uri.js": "bower_components/uri.js/src/URI.js"

	sourceList = _.union ( _.values bowerDeps ), [ "source/*.*" ]

	gulp.task "bower", ->
		bower = require "bower"
		bower.commands.install _.keys bowerDeps

#### test
See `test/karma-config.litcoffee` file for docs on tests.

	gulp.task "test", ->
		# We have to run test suites in different Karma instances
		# as code has a hard to refactor global state.

		# Injected (main) scripts.
		injectedTestStream = gulp.src _.union sourceList,
		[ "test/*.test.litcoffee" ]
			.pipe plugins.karma
				configFile: "test/karma-config.litcoffee"
				port: 9876

		# Chromium meta scripts.
		chromiumTestStream = gulp.src [
			"source/meta/chromium/helpers.litcoffee"
			"test/meta/chromium/helpers.test.litcoffee"
		]
			.pipe plugins.karma
				configFile: "test/karma-config.litcoffee"
				port: 9877

		es.concat injectedTestStream, chromiumTestStream

#### clean-build and clean-dist

	for folder in [ "build", "dist" ]
		do ( folder ) -> gulp.task "clean-#{folder}", ( done ) ->
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
					else done()
			tryRemove()

#### meta

	gulp.task "meta", [ "clean-build" ], ->
		noticeTemplate = fs.readFileSync "./source/meta/notice.template.js"
		
		metaStream = gulp.src "source/meta/*/**/*"
			.pipe plugins.filter "!**/*.ignore.*"
			.pipe plugins.if /\.template\./, plugins.template config
			.pipe plugins.if /\.template\./, plugins.rename ( path ) ->
				path.basename = path.basename.replace /\.template$/, ""
				return
			.pipe plugins.if /\.litcoffee$/, plugins.coffee bare: yes
			.pipe plugins.if /\.litcoffee$/, plugins.rename ( path ) ->
				path.basename = path.basename.replace /\.litcoffee$/, ".js"
				return
			.pipe plugins.if /\.js$/, plugins.header noticeTemplate, config
			.pipe gulp.dest "build"

		licenseStream = gulp.src "LICENSE.md"
			.pipe gulp.dest "build/chromium"
			.pipe gulp.dest "build/firefox"
			.pipe gulp.dest "build/maxthon"
			.pipe gulp.dest "build/opera"

		es.concat metaStream, licenseStream

#### scripts

	gulp.task "scripts", [ "clean-build" ], ->
		baseStream = ->
			gulp.src sourceList
				.pipe plugins.if /\.template\./, plugins.template config
				.pipe plugins.if /\.litcoffee$/, plugins.coffee bare: yes
				.pipe plugins.concat "dist.js"

		injectTransform = plugins.inject baseStream(),
			starttag: "gulpShouldFillThis = \""
			endtag: "\""
			transform: ( path, file ) ->
				escapeString = require "js-string-escape"
				escapeString file.contents

		userscriptHeader = fs.readFileSync "./source/meta/userscript-header.js"
		noticeTemplate = fs.readFileSync "./source/meta/notice.template.js"

		injectStream = gulp.src "source/meta/**/inject.ignore.js"
			.pipe injectTransform
			.pipe plugins.header noticeTemplate, config
			.pipe plugins.if /opera/, plugins.header userscriptHeader
			.pipe plugins.rename basename: "inject"
			.pipe gulp.dest "build"

		distStream = ( baseStream() )
			.pipe plugins.header noticeTemplate, config
			.pipe gulp.dest "build/chromium"
			.pipe gulp.dest "build/firefox/scripts"

		es.concat injectStream, distStream

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
					console.log "Maxthon packager exitted with error:".red,
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
