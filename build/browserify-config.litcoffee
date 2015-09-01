	templateTransform = require "./template-transform"
	base64Transform = require "./base64-transform"

	module.exports = ( type ) ->
		if type is "test"
			plugin = [ "proxyquireify/plugin" ]
			transform = [
				templateTransform
				[ "browserify-coffee-coverage", instrumentor: "istanbul" ]
				"jadeify"
				base64Transform
			]

		else
			plugin = []
			transform = [
				templateTransform
				"coffeeify"
				"jadeify"
				base64Transform
			]

		transform: transform
		plugin: plugin
		extensions: [
			".litcoffee", ".template.litcoffee"
			".js", ".template.js"
			".jade", ".template.jade"
		]
