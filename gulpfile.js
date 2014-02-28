var gulp = require( "gulp" ),
	es = require( "event-stream" ),
	fs = require( "fs-extra" ),
	config = fs.readJsonSync( "./package.json" ),
	userscriptHeader = fs.readFileSync( "./source/meta/userscript-header.js" ),
	noticeTemplate = fs.readFileSync( "./source/meta/notice.template.js" ),
	plugins = require( "gulp-load-plugins" )();

gulp.task( "clean", function() {
	return fs.removeSync( "build" );
});

gulp.task( "meta", [ "clean" ], function() {
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

gulp.task( "default", [ "scripts" ]);
