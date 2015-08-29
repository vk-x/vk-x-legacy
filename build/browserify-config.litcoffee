	templateTransform = require "./template-transform"
	brfsTransform = require "./brfs-transform"

	module.exports = ( type = "build" ) ->
		if type is "test"
			plugin = [ "proxyquireify/plugin" ]
			transform = [
				templateTransform
				[ "browserify-coffee-coverage", instrumentor: "istanbul" ]
				"jadeify"
				brfsTransform
			]

		else
			plugin = []
			transform = [
				templateTransform
				"coffeeify"
				"jadeify"
				brfsTransform
			]

		transform: transform
		plugin: plugin
		extensions: [
			".litcoffee", ".template.litcoffee"
			".js", ".template.js"
			".jade", ".template.jade"
		]
