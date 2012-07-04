sp = getSpotifyApi 1

models = sp.require "sp://import/scripts/api/models"

spotify = (title, artist, done) ->
  search = new models.Search title

  search.observe models.EVENT.CHANGE, () ->
    search.ignore models.EVENT.CHANGE #remove listener
    done search.tracks[0] if search.tracks.length
  search.appendNext()

exports.spotify = spotify