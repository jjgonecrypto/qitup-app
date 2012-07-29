sp = getSpotifyApi 1

models = sp.require "sp://import/scripts/api/models"
results = sp.require "/scripts/js/results"
twitter = sp.require "/scripts/js/twitter"


search = sp.require "/scripts/js/search"
services = [twitter]

init = ->
  lastQuery = undefined
  interval = undefined
  playlist = undefined
  playlistToSave = undefined
  from_date = undefined

  input = document.getElementById "query"
  searchBtn = document.getElementById "search"
  stopBtn = document.getElementById "stop"
  resultsEl = document.getElementById "results"
  twitterBtn = document.getElementById "twitter-btn"
  twitterText = document.getElementById "twitter-user"
  from_now = document.getElementById "from-now"
  save_playlist = document.getElementById "save-playlist"

  searchBtn.addEventListener "click", ->
    clearInterval interval if interval
    interval = setInterval searchServices, 30*1000
    searchServices()
    toggle on

  stopBtn.addEventListener "click", ->
    clearInterval interval if interval
    toggle off

  twitterBtn.addEventListener "click", ->
    twitter.authenticate (response, err) ->
      return console.log("err: ", err) if err
      console.log response
      twitterText.innerHTML = "signed in as <a href='http://twitter.com/#{response.screen_name}'>@#{response.screen_name}</a>"

  toggle = (state) ->
    listening = document.getElementById "listening"
    display = if state then "block" else "none"
    listening.style["display"] = display

  searchServices = ->
    position = 0
    if input.value isnt lastQuery
      lastQuery = input.value
      playlist = new models.Playlist()
      playlistToSave = if save_playlist.checked then new models.Playlist "QItUp: " + lastQuery else null
      from_date = new Date()

    for service in services
      service.search 
        query: input.value
        from_date: if from_now.checked then from_date else null
      , (title, band, request) ->
        console.log "requested: #{title} by #{band}", request
        search.spotify title, band, (track, notFound) ->
          pretty = () => (if title then "#{title}" else "anything") + (if band then " by #{band}" else "")

          return service.message request, "sorry, couldn't find #{pretty()}. pls try again" if notFound
          console.log "spotify found: #{track.name} by #{track.artists[0].name}", track
          
          decoded =
            track: track.name.decodeForText()
            artist: track.artists[0].name.decodeForText()
          
          if playlist.indexOf(track) >= 0
            service.message request, "thanks for the request but \"#{decoded.track}\" has already been played in this playlist"
            return console.log "not queued - already in playlist" 

          unless track.playable
            service.message request, "thanks for the request but \"#{decoded.track}\" isn't available in this region yet. pls try again."
            return console.log "not queued - not playable in region." 

          playlist.add(track)
          playlistToSave.add(track) if playlistToSave

          models.player.play track, playlist, position++ if !models.player.playing and position is 0
          service.message request, "thanks! we queued up \"#{decoded.track}\" by \"#{decoded.artist}\""
          resultsEl.innerHTML = resultsEl.innerHTML + results.add(track, track.artists[0], request) 
exports.init = init