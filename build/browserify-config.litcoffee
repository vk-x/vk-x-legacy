	templateTransform = require "./template-transform"
	brfsTransform = require "./brfs-transform"

	module.exports =
		transform: [ templateTransform, "coffeeify", "jadeify", brfsTransform ]
		plugin: [ "proxyquireify/plugin" ]
		extensions: [
			".litcoffee", ".template.litcoffee"
			".js", ".template.js"
			".jade", ".template.jade"
		]
