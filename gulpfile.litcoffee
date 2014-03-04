	gulp = require "gulp"
	es = require "event-stream"
	path = require "path"
	fs = require "fs-extra"
	colors = require "colors"
	config = require "./package"
	plugins = do require "gulp-load-plugins"
	cwd = do process.cwd

	gulp.task "test", ->
		gulp.src [ "source/*.*", "test/*.test.litcoffee" ]
			.pipe plugins.karma
				configFile: "karma-config"

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
					else do done
			do tryRemove

	gulp.task "meta", [ "clean-build" ], ->
		noticeTemplate = fs.readFileSync "./source/meta/notice.template.js"
		
		metaStream = gulp.src "source/meta/*/**/*"
			.pipe plugins.filter "!**/*.ignore.*"
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

	gulp.task "scripts", [ "clean-build", "test" ], ->
		baseStream = ->
			gulp.src "source/*.*"
				.pipe plugins.if /\.template\./, plugins.template config
				.pipe plugins.if /\.litcoffee$/, plugins.coffee bare: yes
				.pipe plugins.concat "dist.js"

		injectTransform = plugins.inject do baseStream,
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

		distStream = ( do baseStream )
			.pipe plugins.header noticeTemplate, config
			.pipe gulp.dest "build/chromium"
			.pipe gulp.dest "build/firefox/scripts"

		es.concat injectStream, distStream

	gulp.task "dist-maxthon", [ "meta", "scripts", "clean-dist" ], ( done ) ->
		if do ( require "os" ).type isnt "Windows_NT"
			console.log "Maxthon packager only works on Windows.".yellow
			do done

		execFile = ( require "child_process" ).execFile
		resultName = "#{config.name}-#{config.version}-maxthon.mxaddon"
		pathToResult = path.join cwd, "dist", resultName
		pathToSource = path.join cwd, "build", "maxthon"
		pathToBuilder = path.join cwd, "maxthon-packager.exe"

		execFile pathToBuilder, [ pathToSource, pathToResult ], null,
			( error ) ->
				console.log "Maxthon builder exited with error:", error if error
				do done

	gulp.task "dist-zip", [ "meta", "scripts", "clean-dist" ], ->
		prefix = "#{config.name}-#{config.version}"

Firefox allows to install add-ons from .xpi packages
(which are simply zip archives), so you may want to send one
to friends or install it yourself.
It is possible to install unpacked source directly and
auto reload on changes: http://stackoverflow.com/q/15908094

		firefoxStream = gulp.src "**/*.*",
				cwd: path.join cwd, "build", "firefox"
			.pipe plugins.zip "#{prefix}-firefox.xpi"

Chromium (particularly Google Chrome) does not allow
to install extensions from .crx packages not from
Google Chrome Web Store but you may want to send zip-archived
unpacked extension to friends.
How to install unpacked extension:
https://developer.chrome.com/extensions/getstarted#unpacked
It is possible to make it auto reloading on changes:
http://stackoverflow.com/a/12767200
Tip: for now you can use this extension as it has a hotkey:
http://git.io/ujSDUw

		chromiumStream = gulp.src "**/*.*",
				cwd: path.join cwd, "build", "chromium"
			.pipe plugins.zip "#{prefix}-chromium.zip"

Opera 12 only allows to install extensions from .oex packages
which are simply zip archives.

		operaStream = gulp.src "**/*.*",
				cwd: path.join cwd, "build", "opera"
			.pipe plugins.zip "#{prefix}-opera.oex"

		es.concat firefoxStream, chromiumStream, operaStream
			.pipe gulp.dest "dist"

	gulp.task "dist", [ "dist-maxthon", "dist-zip" ]

	gulp.task "build", [ "meta", "scripts" ]

	gulp.task "default", [ "build" ], ->
		gulp.watch [ "source/**/*.*", "test/**/*.*" ], [ "build" ]
