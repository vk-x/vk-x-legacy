module.exports = function( config ) {
	config.set({
		frameworks: [ "mocha", "chai" ],
		files: [
            "source/*.js",
			"test/*.test.js"
		],
		preprocessors: {
			"**/*.template.*": [ "lodash" ]
		},
		lodashPreprocessor: {
			data: require( "./package.json" )
		},
		browsers: [ "PhantomJS" ]
	});
};
