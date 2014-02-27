var gulp = require( "gulp" ),
	es = require( "event-stream" ),
	config = require( "./package.json" ),
	noticeTemplate = require( "fs" )
		.readFileSync( "./source/meta/notice.template.js" ),
	plugins = require( "gulp-load-plugins" )();

gulp.task( "clean", function() {
	return gulp.src( "builds/firefox", { read: false })
		.pipe( plugins.clean() );
});

gulp.task( "meta", [ "clean" ], function() {
	gulp.src( "source/meta/chromium/manifest.json" )
		.pipe( plugins.template( config ) )
		.pipe( gulp.dest( "builds/chromium" ) );

	gulp.src( "source/meta/chromium/inject.js" )
		.pipe( plugins.header( noticeTemplate, config ) )
		.pipe( gulp.dest( "builds/chromium" ) );

	gulp.src([ "source/meta/firefox/**/*", "LICENSE.md" ])
		.pipe( plugins.if( /\.template\./, plugins.template( config ) ) )
		.pipe( plugins.if( /\.template\./, plugins.rename(function( path ) {
			path.basename = path.basename.replace( ".template", "" );
		}) ) )
		.pipe( plugins.if( /\.js$/, plugins.header( noticeTemplate, config ) ) )
		.pipe( gulp.dest( "builds/firefox" ) );

	gulp.src( "source/meta/maxthon/def.json" )
		.pipe( plugins.template( config ) )
		.pipe( gulp.dest( "builds/maxthon" ) );

	gulp.src( "source/meta/opera/config.xml" )
		.pipe( plugins.template( config ) )
		.pipe( gulp.dest( "builds/opera" ) );
});

gulp.task( "scripts", [ "meta" ], function() {
	var baseStream = gulp.src( "source/*.js" )
			.pipe( plugins.if( /\.template\.js/, plugins.template( config ) ) )
			.pipe( plugins.concat( "dist.js" ) );

		distStream = baseStream
			.pipe( plugins.header( noticeTemplate, config ) )
			.pipe( gulp.dest( "builds/chromium" ) )
			.pipe( gulp.dest( "builds/firefox/scripts" ) ),

		maxthonStream = baseStream
			.pipe( plugins.inject( "source/meta/maxthon/inject.js", {
				starttag: "gulpShouldFillThis = \"",
				endtag: "\"",
				transform: function( filepath, file ) {
					var escapeString = require( "js-string-escape" );
					return escapeString( file.contents );
				}
			}) )
			.pipe( plugins.header( noticeTemplate, config ) )
			.pipe( gulp.dest( "builds/maxthon" ) ),

		operaStream = baseStream
			.pipe( plugins.inject( "source/meta/opera/inject.js", {
				starttag: "window.eval( \"",
				endtag: "\" );",
				transform: function( filepath, file ) {
					var escapeString = require( "js-string-escape" );
					return escapeString( file.contents );
				}
			}) )
			.pipe( plugins.header( noticeTemplate, config ) )
			.pipe( gulp.dest( "builds/opera/includes" ) );

		return es.concat( distStream, maxthonStream, operaStream );
});

gulp.task( "default", [ "scripts" ]);
