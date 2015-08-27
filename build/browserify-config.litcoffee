	templateTransform = require "./template-transform"
	brfsTransform = require "./brfs-transform"

	module.exports =
		transform: [ templateTransform, "coffeeify", "jadeify", brfsTransform ]
		extensions: [
			".litcoffee", ".template.litcoffee"
			".js", ".template.js"
			".jade", ".template.jade"
		]
