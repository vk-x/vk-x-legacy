[tests]: ../test/unit/photo.litcoffee

**Note**: see [tests][tests] for API documentation.
This file only contains notes on internal details.

# `photo` module

	modal = require "./modal"
	vkApi = require "./vk-api"
	i18n = require "./i18n"
	saveFile = require "./save-file"
	saveAsPolyfill = require "filesaver.js"

	photo =

## `photo.getBestQualityUrl`

		getBestQualityUrl: ( photoInfo ) ->
			photoInfo.photo_2560 ?
			photoInfo.photo_1280 ?
			photoInfo.photo_807 ?
			photoInfo.photo_604 ?
			photoInfo.photo_130 ?
			photoInfo.photo_75

## `photo.normalizeAlbumId`

		normalizeAlbumId: ( rawId ) ->
			rawId = "#{rawId}"
			switch rawId
				when "000" then "saved"
				when "00" then "wall"
				when "0" then "profile"
				else rawId

## `photo.downloadAlbumAsZip`

		downloadAlbumAsZip: ({ ownerId, albumId, callback } = {}) ->
			if not callback
				throw new Error "Callback is not specified!"

			albumId = photo.normalizeAlbumId albumId

			progressBar = modal.showProgressBar
				title: i18n.t "downloadingPhotosToZipTitle"
				content: i18n.t "downloadingPhotosToZipText"
				dark: yes

			vkApi.request
				method: "photos.get"
				data:
					owner_id: ownerId
					album_id: albumId
					rev: 1
				callback: ( result ) ->
					if result.error
						callback new Error result.error
						return

					photos = result.response.items

					saver = saveFile.saveMultipleAsZip concurrency: 6
					saver.afterEach ( filename, doneCount, totalCount ) ->
						if not progressBar.isVisible()
							saver.kill()
							callback new Error "The user has cancelled downloading."
							return
						progressBar.setProgress Math.round 100 * doneCount / totalCount

					photos.forEach ( photoInfo, i ) ->
						saver.add
							url: photo.getBestQualityUrl photoInfo
							filename: "#{i + 1}_#{photoInfo.id}.jpg"

					saver.zip ( zipBlob ) ->
						saveAsPolyfill.saveAs zipBlob, "album#{ownerId}_#{albumId}.zip"
						progressBar.hide()
						callback()

	module.exports = photo
