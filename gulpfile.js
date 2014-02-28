var gulp = require( "gulp" ),
	es = require( "event-stream" ),
	path = require( "path" ),
	fs = require( "fs-extra" ),
	config = fs.readJsonSync( "./package.json" ),
	userscriptHeader = fs.readFileSync( "./source/meta/userscript-header.js" ),
	noticeTemplate = fs.readFileSync( "./source/meta/notice.template.js" ),
	plugins = require( "gulp-load-plugins" )();

gulp.task( "clean-build", function() {
	return fs.removeSync( "build" );
});

gulp.task( "meta", [ "clean-build" ], function() {
	var metaStream = gulp.src( "source/meta/*/**/*" )
			.pipe( plugins.filter( "!**/*.ignore.*" ) )
			.pipe( plugins.if( /\.template\./, plugins.template( config ) ) )
			.pipe( plugins.if( /\.template\./, plugins.rename(function( path ) {
				path.basename = path.basename.replace( ".template", "" );
			}) ) )
			.pipe( plugins.if( /\.js$/,
				plugins.header( noticeTemplate, config )
			) )
			.pipe( gulp.dest( "build" ) ),

		licenseStream = gulp.src( "LICENSE.md" )
			.pipe( gulp.dest( "build/chromium" ) )
			.pipe( gulp.dest( "build/firefox" ) )
			.pipe( gulp.dest( "build/maxthon" ) )
			.pipe( gulp.dest( "build/opera" ) );

	return es.concat( metaStream, licenseStream );
});

gulp.task( "scripts", [ "meta" ], function() {
	var baseStream = function() {
			return gulp.src( "source/*.js" )
				.pipe( plugins.if( /\.template\.js/,
					plugins.template( config ) ) )
				.pipe( plugins.concat( "dist.js" ) );
		},

		injectTransform = plugins.inject( baseStream(), {
			starttag: "gulpShouldFillThis = \"",
			endtag: "\"",
			transform: function( filepath, file ) {
				var escapeString = require( "js-string-escape" );
				return escapeString( file.contents );
			}
		}),

		injectStream = gulp.src( "source/meta/**/inject.ignore.js" )
			.pipe( injectTransform )
			.pipe( plugins.header( noticeTemplate, config ) )
			.pipe( plugins.if( /opera/, plugins.header( userscriptHeader ) ) )
			.pipe( plugins.rename({ basename: "inject" }) )
			.pipe( gulp.dest( "build" ) ),

		distStream = baseStream()
			.pipe( plugins.header( noticeTemplate, config ) )
			.pipe( gulp.dest( "build/chromium" ) )
			.pipe( gulp.dest( "build/firefox/scripts" ) ),

		vendorStream = gulp.src( "source/vendor/*.js" )
			.pipe( gulp.dest( "build/chromium" ) );

	return es.concat( injectStream, distStream, vendorStream );
});

gulp.task( "clean-dist", function() {
	return fs.removeSync( "dist" );
});

gulp.task( "dist-maxthon", [ "scripts", "clean-dist" ], function( done ) {
	if ( require( "os" ).type() !== "Windows_NT" ) {
		return done();
	}

	var execFile = require( "child_process" ).execFile,
		resultName = config.name + "-" + config.version + "-maxthon.mxaddon",
		pathToResult = path.join( process.cwd(), "dist", resultName ),
		pathToSource = path.join( process.cwd(), "build", "maxthon" ),
		pathToBuilder = path.join( process.cwd(), "maxthon-packager.exe" );

	execFile( pathToBuilder, [ pathToSource, pathToResult ], null,
		function( error ) {
			if ( error ) {
				console.log( "Maxthon builder exited with error:", error );
			}
			done();
		}
	);
});

gulp.task( "dist-zip", [ "scripts", "clean-dist" ], function() {
	var prefix = config.name + "-" + config.version,

		// Firefox allows to install add-ons from .xpi packages
		// (which are simply zip archives), so you may want to send one
		// to friends or install it yourself.
		// It is possible to install unpacked source directly and
		// auto reload on changes: http://stackoverflow.com/q/15908094
		firefoxStream = gulp.src( "**/*.*", {
			cwd: path.join( process.cwd(), "build", "firefox" )
		}).pipe( plugins.zip( prefix + "-firefox.xpi" ) ),

		// Chromium (particularly Google Chrome) does not allow
		// to install extensions from .crx packages not from
		// Google Chrome Web Store but you may want to send zip-archived
		// unpacked extension to friends.
		// How to install unpacked extension:
		// https://developer.chrome.com/extensions/getstarted#unpacked
		// It is possible to make it auto reloading on changes:
		// http://stackoverflow.com/a/127672001
		chromiumStream = gulp.src( "**/*.*", {
			cwd: path.join( process.cwd(), "build", "chromium" )
		}).pipe( plugins.zip( prefix + "-chromium.zip" ) ),

		// Opera 12 only allows to install extensions from .oex packages
		// which are simply zip archives.
		operaStream = gulp.src( "**/*.*", {
			cwd: path.join( process.cwd(), "build", "opera" )
		}).pipe( plugins.zip( prefix + "-opera.oex" ) );

	return es.concat( firefoxStream, chromiumStream, operaStream )
		.pipe( gulp.dest( "dist" ) );
});

gulp.task( "dist", [ "dist-maxthon", "dist-zip" ]);

gulp.task( "default", [ "scripts" ]);
