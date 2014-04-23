	through = require "through"
	brfs = require "brfs"

	module.exports = ( file, opts ) ->
		if -1 is file.indexOf "node_modules"
			brfs file, opts
		else
			through()
