var gulp = require( "gulp" ),
	plugins = require( "gulp-load-plugins" )();

gulp.task( "scripts", function() {
	return gulp.src( "source/*.js" )
		.pipe( plugins.concat( "happy.js" ) )
		.pipe( gulp.dest( "builds/chromium/scripts" ) )
		.pipe( gulp.dest( "builds/firefox/scripts" ) )
		.pipe( gulp.dest( "builds/maxthon/scripts" ) )
		.pipe( gulp.dest( "builds/opera/scripts" ) );
});

gulp.task( "default", [ "scripts" ]);
