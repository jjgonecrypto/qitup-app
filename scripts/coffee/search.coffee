sp = getSpotifyApi 1

models = sp.require "sp://import/scripts/api/models"

spotify = (title, artist, done) ->
  query = "track:#{title}"
  query += " artist:#{artist}" if artist
  search = new models.Search query

  search.observe models.EVENT.CHANGE, () ->
    search.ignore models.EVENT.CHANGE #remove listener
    done search.tracks[0] if search.tracks.length
  search.appendNext()

exports.spotify = spotify