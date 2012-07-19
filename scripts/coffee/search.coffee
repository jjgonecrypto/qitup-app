sp = getSpotifyApi 1

models = sp.require "sp://import/scripts/api/models"

models.session.observe models.EVENT.STATECHANGED, () ->
  if models.session.state is 1 
    console.log "online!"
  else
    console.log "disconnected :(" 

spotify = (title, artist, done) ->
  query = ""
  query += " track:#{title}" if title
  query += " artist:#{artist}" if artist
  search = new models.Search query

  search.observe models.EVENT.CHANGE, () ->
    search.ignore models.EVENT.CHANGE #remove listener
    if search.tracks.length 
      done search.tracks[0]
    else 
      console.log "no tracks found for: #{query}" 
      done null, true

  search.observe models.EVENT.LOAD_ERROR, (err) ->
    search.ignore models.EVENT.LOAD_ERROR #remove listener
    console.log "error searching spotify: ", err

  search.appendNext()

exports.spotify = spotify