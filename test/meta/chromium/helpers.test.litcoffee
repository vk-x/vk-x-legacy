# Chromium helpers test suite
See `source/meta/chromium/helpers.litcoffee`.

	describe "chromium inject script", ->

### makeAjaxRequest
This test suite is not full and probably never be full for old ajax interface.
Better go refactor it or implement new one.

		describe "makeAjaxRequest", ->
			xhr = null
			before -> xhr = sinon.useFakeXMLHttpRequest()
			after -> xhr.restore()

			it "should not do anything with irrelevant message", ->
				xhr.onCreate = sinon.stub().throws Error "Unwanted request!"

				( makeAjaxRequest sinon.stub().throws() ) data:
					mark: "irrelevant message"
					act: "get"
					url: "http://example.com/"
					_sub: "you should not care about _sub"

			it "should not do anything with incorrect data", ->
				xhr.onCreate = sinon.stub().throws Error "Unwanted request!"

				( makeAjaxRequest sinon.stub().throws() ) data:
					mark: "vkopt_loader"
					act: "LOLWTF"
					url: "http://example.com/"
					_sub: "you should not care about _sub"

				( makeAjaxRequest sinon.stub().throws() ) data:
					mark: "vkopt_loader"
					act: "GET"
					url: "http://example.com/"

				# It can't be called without act or url because only
				# old code consumes this interface, and it does it right.

			it "should make GET request and pass response to callback", ->
				requests = []
				xhr.onCreate = ( request ) -> requests.push request

				callback = sinon.spy()

				( makeAjaxRequest callback ) data:
					mark: "vkopt_loader"
					act: "GET"
					url: "http://example.com/"
					_sub: "you should not care about _sub"

				requests.length.should.be.equal 1
				requests[ 0 ].method.should.be.equal "GET"
				requests[ 0 ].url.should.be.equal "http://example.com/"
				requests[ 0 ].respond 200, "Content-Type": "text/plain", "ok"
				callback.should.have.been.calledOnce

### inject
**inject()** helper is simple enough not to test it.
See: http://stackoverflow.com/a/9517879.
