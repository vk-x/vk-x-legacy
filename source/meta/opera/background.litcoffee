This script runs in background and has a permission
to do cross-origin ajax requests.
See: `source/meta/opera/index.html`.

	done = ( win, response ) -> win.postMessage response
	opera.extension.onmessage = makeAjaxRequest done
