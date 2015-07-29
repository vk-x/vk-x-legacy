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


## `photo.downloadAlbumAsZip`

		describe "downloadAlbumAsZip", ->

			# TODO: Refactor this method to the point of testability.
			it "exists", ->
				photo.downloadAlbumAsZip.should.be.a "function"
