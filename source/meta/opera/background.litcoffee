This script runs in background and has a permission
to do cross-origin ajax requests.
See: `source/meta/opera/index.html`.

	app = require "../../app"
	performRequest = require( "../../ajax/perform-request" ) app

	opera.extension.onmessage = performRequest
