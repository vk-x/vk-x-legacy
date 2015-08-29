	through = require "through2"
	config = require "../package"
	_ = require "lodash"

	# https://github.com/substack/node-browserify#btransformtr-opts
	templateTransform = ( fileName ) ->
		return through() if -1 is fileName.indexOf ".template."

		content = ""
		write = ( chunk, enc, callback ) ->
			content += chunk.toString "utf8"
			callback()
		end = ( callback ) ->
			@push new Buffer _.template( content ) config
			callback()

		through.obj write, end

	module.exports = templateTransform
