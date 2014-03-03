	module.exports = ( config ) ->
		config.set
			files: [
				"source/*.*"
				"test/*.test.litcoffee" ]

			frameworks: [ "mocha", "chai" ]

			preprocessors:
				"**/*.template.*": [ "lodash" ]
				"**/*.litcoffee": [ "coffee" ]

			lodashPreprocessor:
				data: require "./package.json"

			browsers: [ "PhantomJS" ]
