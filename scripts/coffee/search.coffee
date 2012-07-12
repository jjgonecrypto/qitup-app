sp = getSpotifyApi 1

models = sp.require "sp://import/scripts/api/models"

spotify = (title, artist, done) ->
  query = "track:#{title}"
  query += " artist:#{artist}" if artist
  search = new models.Search query

  search.observe models.EVENT.CHANGE, () ->
    search.ignore models.EVENT.CHANGE #remove listener
    if search.tracks.length 
      done search.tracks[0]
    else 
      console.log "no tracks found for #{title} by #{artist}" 

  search.observe models.EVENT.LOAD_ERROR, (err) ->
    search.ignore models.EVENT.LOAD_ERROR #remove listener
    console.log "error searching spotify: ", err

  search.appendNext()

exports.spotify = spotify