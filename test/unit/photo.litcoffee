# `photo` module

	describe "photo", ->

		photo = require "../../source/photo"

## What?

**`photo`** module works with photos, enchancing user experience with them and
adding new features.

## Why?

Because VK misses some useful features related to photos.

## How?

#### API

```CoffeeScript
photo = require "./photo"

photo.downloadAlbumAsZip
	ownerId: "123"
	albumId: "456"
	callback: ( error ) ->
		throw error if error
```

## `photo.getBestQualityUrl`

Usage:

```CoffeeScript
# Get a photo object
vkApi.request
	method: "photos.get"
	data: ...
	callback: ( result ) ->
		returnedPhotos = result.response.items
		# Now get the best quality URL
		url = photo.getBestQualityUrl returnedPhotos[ 0 ]
```

Returns a link to the largest available size of a [photo](https://vk.com/dev/photos.get).

The photo object should have `photo_<size>` properties instead of `sizes` array.
In other words, use `photo_sizes: 0` when calling [`photos.get`](https://vk.com/dev/photos.get).

		describe "getBestQualityUrl", ->

			[ "2560", "1280", "807", "604", "130", "75" ].forEach ( size, i, sizes ) ->
				it "should return photo_#{size} if it's the best size available", ->
					availableSizes = sizes.slice i
					fakePhotoInfo = {}
					availableSizes.forEach ( size ) ->
						fakePhotoInfo[ "photo_#{size}" ] = "fake-link-#{size}"

					result = photo.getBestQualityUrl fakePhotoInfo

					result.should.equal fakePhotoInfo[ "photo_#{size}" ]

## `photo.normalizeAlbumId`

Usage:

```CoffeeScript
normalizedId = photo.normalizeAlbumId rawId
```

Normalizes an album id if necesary. For example, if you parse it from the url,
you might get `"000"`. But the API expects you to use `"saved"` as an id in that
case. This function handles such cases and return an API-ready album id.

		describe "normalizeAlbumId", ->

			[
				[ "000", "saved" ]
				[ "saved", "saved" ]
				[ "00", "wall" ]
				[ "wall", "wall" ]
				[ "0", "profile" ]
				[ 0, "profile" ]
				[ "profile", "profile" ]
				[ "123", "123" ]
				[ 123, "123" ]
			].forEach ([ rawId, normalizedId ]) ->
				it "should normalize #{rawId} as #{normalizedId}", ->
					result = photo.normalizeAlbumId rawId
					result.should.equal normalizedId

## `photo.downloadAlbumAsZip`

		describe "downloadAlbumAsZip", ->

			modal = require "../../source/modal"
			i18n = require "../../source/i18n"
			vkApi = require "../../source/vk-api"
			saveFile = require "../../source/save-file"

			it "should use saveFile.saveMultipleAsZip", ( done ) ->
				sinon.stub photo, "normalizeAlbumId", ( albumId ) ->
					albumId.should.equal "fake-album-id"
					"fake-normalized-album-id"

				sinon.stub photo, "getBestQualityUrl", ( photoInfo ) ->
					"fake-url-#{photoInfo.id}"

				progressBar =
					isVisible: -> yes
					setProgress: sinon.stub()
					hide: sinon.stub()
				sinon.stub modal, "showProgressBar", ->
					progressBar

				sinon.stub i18n, "t", ->
					"fake-translation"

				# Can't stub global.saveAs, it's a property - not a function.
				originalSaveAs = global.saveAs
				global.saveAs = sinon.spy ( zipBlob ) ->
					zipBlob.should.equal "fake-zip-blob"

				sinon.stub saveFile, "saveMultipleAsZip", ({ concurrency }) ->
					concurrency.should.be.a "number"

					addedFiles = []
					afterEachCallback = null
					afterEach: ( callback ) ->
						afterEachCallback = callback
					add: ({ url, filename }) ->
						addedFiles.push { url, filename }
						afterEachCallback? filename, addedFiles.length, addedFiles.length
					zip: ( callback ) ->
						addedFiles.should.deep.equal [
							url: "fake-url-foo"
							filename: "1_foo.jpg"
						,
							url: "fake-url-bar"
							filename: "2_bar.jpg"
						,
							url: "fake-url-qux"
							filename: "3_qux.jpg"
						]
						callback "fake-zip-blob"

				sinon.stub vkApi, "request", ({ method, data, callback }) ->
					method.should.equal "photos.get"
					data.should.deep.equal
						owner_id: "fake-owner-id"
						album_id: "fake-normalized-album-id"
						rev: 1
					callback response: items: [
							id: "foo"
						,
							id: "bar"
						,
							id: "qux"
						]

				photo.downloadAlbumAsZip
					ownerId: "fake-owner-id"
					albumId: "fake-album-id"
					callback: ->
						photo.normalizeAlbumId.should.have.been.calledOnce
						photo.normalizeAlbumId.restore()

						photo.getBestQualityUrl.restore()

						modal.showProgressBar.should.have.been.calledOnce
						modal.showProgressBar.restore()

						vkApi.request.should.have.been.calledOnce
						vkApi.request.restore()

						saveFile.saveMultipleAsZip.restore()

						progressBar.hide.should.have.been.calledOnce

						i18n.t.restore()

						global.saveAs.should.have.been.calledOnce
						global.saveAs = originalSaveAs

						done()
