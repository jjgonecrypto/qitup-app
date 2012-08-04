sp = getSpotifyApi 1

models = sp.require "sp://import/scripts/api/models"
results = sp.require "/scripts/js/results"
twitter = sp.require "/scripts/js/twitter"
matcher = sp.require "/scripts/js/matcher"
queuer = sp.require "/scripts/js/queuer"

ç = sp.require("/scripts/js/swah").swah

services = [twitter]

init = ->
  lastQuery = undefined
  interval = undefined
  playlist = undefined
  playlistToSave = undefined
  from_date = undefined

  ç("#query").on "focus", -> ç("#query").removeClass("invalid")

  ç(".search-btn").on "click", -> 
    return ç("#query").className("invalid") unless ç("#query").val().trim().length > 0
    startSearchingOn(ç("#search-type").val() + ç("#query").val())

  ç(".stop-btn").on "click", ->
    clearInterval interval if interval
    queuer.turn off
    toggle off

  ç("#twitter-btn").on "click", ->
    twitter.authenticate (response, err) ->
      return console.log("err: ", err) if err
      console.log response
      ç(".twitter-status").html "successfully signed in as <a class='twitter-username' href='http://twitter.com/#{response.screen_name}'>@#{response.screen_name}</a>"
      ç("#twitter-service").className "auth-state"

  ç(".new-search-btn").on "click", ->
    ç("#powerbar").className "new-state"
    ç("#query").val ""
    ç("#results").html ""

  ç("#twitter-signout-btn").on "click", ->
    twitter.signout (err) ->
      if err
        ç(".twitter-status").html "error signing out. please try again."
      else
        ç(".twitter-status").html "signed out."
        ç("#twitter-service").className "unauth-state"

  ç(".resume-btn").on "click", -> 
    startSearchingOn lastQuery
    queuer.turn on

  startSearchingOn = (query) ->
    clearInterval interval if interval
    interval = setInterval (() -> searchServices query), 30*1000
    searchServices query
    toggle on
    ç(".search-query").html query   
    
  toggle = (state) ->
    ç("#powerbar").className(if state then "listen-state" else "stop-state")

  searchServices = (query) ->
    position = 0

    if query isnt lastQuery
      lastQuery = query
      playlist = new models.Playlist()
      playlistToSave = if ç("#save_playlist").checked() then new models.Playlist "QItUp: " + lastQuery else null
      from_date = new Date()
      queuer.reset() and queuer.turn on
      ç("#results").html ""

    for service in services
      service.search 
        query: query
        from_date: if ç("#from-now").checked() then from_date else null
      , (request) ->
        matcher.match request.stripped, (match) ->
          unless match
            console.log "no match for tweet", request.text
            return ç("#results").append(results.notQueued("(QItUp couldn't find a song request.", request)).addClass "appear"

          console.log "requested: #{match.track} by #{match.artist}", request
          queuer.add match, request, (track, notFound) ->
            pretty = () => (if match.track then "#{match.track}" else "anything") + (if match.artist then " by #{match.artist}" else "")
           
            if notFound
              ç("#results").append(results.notQueued("(Spotify couldn't find: #{pretty()})", request)).addClass "appear"
              return service.message request, "sorry, couldn't find #{pretty()}. pls try again" 
            
            console.log "spotify found: #{track.name} by #{track.artists[0].name}", track
            
            decoded =
              track: track.name.decodeForText()
              artist: track.artists[0].name.decodeForText()
            
            if playlist.indexOf(track) >= 0
              service.message request, "thanks for the request but \"#{decoded.track}\" has already been played in this playlist"
              ç("#results").append(results.notQueued("(Already in queue: #{decoded.track})", request)).addClass "appear"
              return console.log "not queued - already in playlist" 

            unless track.playable
              service.message request, "thanks for the request but \"#{decoded.track}\" isn't available in this region yet. pls try again."
              ç("#results").append(results.notQueued("(Not playable in this region: #{decoded.track})", request)).addClass "appear"
              return console.log "not queued - not playable in region." 

            playlist.add(track)
            playlistToSave.add(track) if playlistToSave

            models.player.play track, playlist, position++ if !models.player.playing and position is 0
            service.message request, "thanks! we queued up \"#{decoded.track}\" by \"#{decoded.artist}\""
            ç("#results").append(results.queued(track, track.artists[0], request)).addClass "appear"

exports.init = init