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

			# TODO: Refactor this method to the point of testability.
			it "exists", ->
				photo.downloadAlbumAsZip.should.be.a "function"
