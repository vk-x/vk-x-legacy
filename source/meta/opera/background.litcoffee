This script runs in background and has a permission
to do cross-origin ajax requests.
See: `source/meta/opera/index.html`.

	handleAjax = require "../handle-ajax"

	opera.extension.onmessage = handleAjax
