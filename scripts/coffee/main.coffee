sp = getSpotifyApi 1

models = sp.require "sp://import/scripts/api/models"
helper = sp.require "/scripts/js/helper"
twitter = sp.require "/scripts/js/twitter"

search = sp.require "/scripts/js/search"
services = [twitter]

init = ->
  lastQuery = undefined
  interval = undefined
  playlist = undefined
  playlistToSave = undefined
  input = document.getElementById "query"
  searchBtn = document.getElementById "search"
  stopBtn = document.getElementById "stop"
  results = document.getElementById "results"
  twitterBtn = document.getElementById "twitter-btn"
  twitterText = document.getElementById "twitter-user"

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
      playlistToSave = new models.Playlist "twimote: " + lastQuery #required to keep track of playlist 
      results.innerHTML = ''

    for service in services
      service.search input.value, (title, band, request) ->
        console.log "requested: #{title} by #{band}", request
        search.spotify title, band, (track, notFound) ->
          pretty = () => (if title then "\"#{title}\"" else "anything") + (if band then " by #{band}" else "")

          return service.message request, "sorry, couldn't find #{pretty()}. pls try again" if notFound
          console.log "spotify found: #{track.name} by #{track.artists[0].name}", track
          if playlist.indexOf(track) >= 0
            service.message request, "thanks for the request but \"#{track.name}\" has already been played in this playlist"
            return console.log "not queued - already in playlist" 
          playlist.add(track) and playlistToSave.add(track)
          models.player.play track, playlist, position++ if !models.player.playing and position is 0
          service.message request, "thanks! we queued up \"#{track.name}\" by \"#{track.artists[0].name}\""
          entry = document.createElement('li')
          html = "<ul class='inline'>"
          html += "<li>#{helper.image(track.image)}</li>"
          html += "<li class='track'><a class='track-link' href=\"#{track.uri}\">#{track.name}</a><br />by <a href=\"#{track.artists[0].uri}\">#{track.artists[0].name}</a></li>"
          html += "<li>#{helper.image(request.avatar_uri)}</li>"
          html += "<li class='user'><a href='#{request.profile_uri}'>#{request.fullname} (@#{request.username})</a><br />"
          html += "<div class='request-text'>#{request.text}</div></li>"
          html += "</ul>"
          results.appendChild entry
          entry.innerHTML = html
exports.init = init