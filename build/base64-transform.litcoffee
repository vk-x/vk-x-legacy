	through = require "through2"
	path = require "path"
	fs = require "fs"
	escapeString = require "js-string-escape"

	extensions = [
		".png"
		".jpg"
	]

	# https://github.com/substack/node-browserify#btransformtr-opts
	base64Transform = ( fileName ) ->
		unless path.extname( fileName ) in extensions
			return through()

		content = fs.readFileSync fileName, encoding: "base64"
		code = "module.exports = \"#{escapeString content}\";"

		write = ( chunk, enc, callback ) ->
			callback()
		end = ( callback ) ->
			@push new Buffer code
			callback()

		through.obj write, end

	module.exports = base64Transform
