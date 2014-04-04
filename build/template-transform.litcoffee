	through = require "through"
	config = require "../package"
	_ = require "lodash"

	# https://github.com/substack/node-browserify#btransformopts-tr
	templateTransform = ( fileName ) ->
		return through() if -1 is fileName.indexOf ".template."

		content = ""
		write = ( buffer ) -> content += buffer
		end = ->
			@queue _.template content, config
			@queue null

		through write, end

	module.exports = templateTransform
