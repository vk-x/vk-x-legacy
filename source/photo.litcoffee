[tests]: ../test/unit/photo.litcoffee

**Note**: see [tests][tests] for API documentation.
This file only contains notes on internal details.

# `photo` module

	Blob = require "blob"
	JsZip = require "jszip"
	saveAs = require "filesaver.js"
	modal = require "./modal"
	vkApi = require "./vk-api"
	i18n = require "./i18n"
	saveFile = require "./save-file"

	photo =

## `photo.getBestQualityUrl`

		getBestQualityUrl: ( photoInfo ) ->
			photoInfo.photo_2560 ?
			photoInfo.photo_1280 ?
			photoInfo.photo_807 ?
			photoInfo.photo_604 ?
			photoInfo.photo_130 ?
			photoInfo.photo_75

## `photo.downloadAlbumAsZip`

		downloadAlbumAsZip: ({ ownerId, albumId, callback } = {}) ->
			callback ?= ->

			if albumId is "000"
				albumId = "saved"
			else if albumId is "00"
				albumId = "wall"
			else if albumId is "0"
				albumId = "profile"

			progressBox = modal.showProgressBar
				title: i18n.t "downloadingPhotosToZipTitle"
				content: i18n.t "downloadingPhotosToZipText"
				dark: yes

			vkApi.request
				method: "photos.get"
				data:
					owner_id: ownerId
					album_id: albumId
					rev: 1
				callback: ( result ) =>
					if result.error
						callback new Error result.error

					photos = result.response.items

					zip = new JsZip

					addPhotoToZip = ( photoIndex ) =>
						if photoIndex >= photos.length
							zipBlob = zip.generate type: "blob"
							saveAs zipBlob, "album#{ownerId}_#{albumId}.zip"
							progressBox.hide()
							callback()
							return

						photoInfo = photos[ photoIndex ]

						link = @getBestQualityUrl photoInfo

						filename = "#{photoIndex + 1}_#{photoInfo.id}.jpg"

						saveFile.download
							url: link
							callback: ( err, file ) ->
								if err
									callback err
									return

								if not progressBox.isVisible()
									callback new Error "The user has cancelled downloading."
									return

								zip.file filename, file
								progressBox.setProgress Math.round 100 * photoIndex / photos.length
								setTimeout -> addPhotoToZip photoIndex + 1

					addPhotoToZip 0

	module.exports = photo
