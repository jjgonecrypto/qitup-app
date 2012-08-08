sp = getSpotifyApi 1

models = sp.require "sp://import/scripts/api/models"

online = true
endCurrentSearch = undefined

models.session.observe models.EVENT.STATECHANGED, () ->
  if models.session.state is 1 
    console.log "online!"
    online = true
  else
    console.log "disconnected :("
    online = false 
    endCurrentSearch("disconnected") if endCurrentSearch instanceof Function


spotify = (title, artist, album, random, done) ->
  query = ""
  query += " track:#{title}" if title
  query += " artist:#{artist}" if artist
  query += " album:#{album}" if album
  search = new models.Search query

  complete = () -> 
    search.ignore models.EVENT.CHANGE 
    search.ignore models.EVENT.LOAD_ERROR 
    endCurrentSearch = undefined
    done.apply {}, arguments

  endCurrentSearch = (msg) -> 
    console.log "ending search due to: #{msg}"
    complete null, false, msg

  return endCurrentSearch "offline" unless online 

  search.observe models.EVENT.CHANGE, () ->
    if search.tracks.length 
      index = if random then Math.floor(Math.random() * search.tracks.length) else 0
      complete search.tracks[index]
    else 
      console.log "no tracks found for: #{query}" 
      complete null, true

  search.observe models.EVENT.LOAD_ERROR, (err) ->
    console.log "error searching spotify: ", err
    complete null, false, err

  search.appendNext()

exports.spotify = spotify