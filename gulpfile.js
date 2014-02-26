var gulp = require( "gulp" ),
	config = require( "./package.json" ),
	plugins = require( "gulp-load-plugins" )();

gulp.task( "scripts", function() {
	var baseStream = gulp.src( "source/*.js" )
			.pipe( plugins.if( /\.template\.js/, plugins.template( config ) ) )
			.pipe( plugins.concat( "dist.js" ) )
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
			.pipe( gulp.dest( "builds/opera/includes" ) );
});

gulp.task( "meta", function() {
	gulp.src( "source/meta/chromium/manifest.json" )
		.pipe( plugins.template( config ) )
		.pipe( gulp.dest( "builds/chromium" ) );

	gulp.src([ "source/meta/firefox/install.rdf",
		"source/meta/firefox/chrome.manifest" ])
		.pipe( plugins.template( config ) )
		.pipe( gulp.dest( "builds/firefox" ) );

	gulp.src( "source/meta/maxthon/def.json" )
		.pipe( plugins.template( config ) )
		.pipe( gulp.dest( "builds/maxthon" ) );

	gulp.src( "source/meta/opera/config.xml" )
		.pipe( plugins.template( config ) )
		.pipe( gulp.dest( "builds/opera" ) );
});

gulp.task( "default", [ "scripts", "meta" ]);
