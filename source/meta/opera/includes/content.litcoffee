Opera 12 does not allow to access resources from web,
so script file injection is only possible with background
script which does have access to local resources.
Originally **VkOpt** used background script which loaded source files
and passed them to this script as strings. They were then
`eval`ed here.
Now we use **gulp** to concat source code and inject it below.

These two event handlers and [`index.html`](../index.html) provide an interface
for same-origin and cross-origin ajax.  
See: [`test/ajax.litcoffee`](../../../../test/unit/ajax.litcoffee).

	app = require "../../../app"

	opera.extension.addEventListener "message", ({ data }) ->
		# Pass response from background.litcoffee to injected script.
		window.postMessage data, "*"
	, false

	window.addEventListener "message", ({ data }) ->
		return unless data.requestOf is app.name
		# Pass request to background.litcoffee
		data.sourceUrl = window.location.href
		opera.extension.postMessage data
	, false

Although this file runs in the page context, there're some
weird errors when trying to run source code without `eval()`.
Needs further investigation because `eval()` is too slow to leave it so.

	# See: gulpfile.litcoffee
	sourceForTop = "This will be replaced with the source"
	sourceForFrames = "This will be replaced with the source"

	# See: background.js:10
	if window is window.top
		window.eval sourceForTop
	else
		window.eval sourceForFrames
