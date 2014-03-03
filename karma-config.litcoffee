	module.exports = ( config ) ->
		config.set
			files: [
				"source/*.js"
				"test/*.test.js" ]

			frameworks: [ "mocha", "chai" ]

			preprocessors:
				"**/*.template.*": [ "lodash" ]

			lodashPreprocessor:
				data: require "./package.json"

			browsers: [ "PhantomJS" ]
