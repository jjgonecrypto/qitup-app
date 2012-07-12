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
  input = document.getElementById "query"
  searchBtn = document.getElementById "search"
  stopBtn = document.getElementById "stop"
  results = document.getElementById "results"
  searchBtn.addEventListener "click", ->
    clearInterval interval if interval
    interval = setInterval searchServices, 30*1000
    searchServices()
    toggle on

  stopBtn.addEventListener "click", ->
    clearInterval interval if interval
    toggle off

  toggle = (state) ->
    listening = document.getElementById "listening"
    display = if state then "block" else "none"
    listening.style["display"] = display

  searchServices = ->
    if input.value isnt lastQuery
      playlist = new models.Playlist()
      results.innerHTML = ''
      lastQuery = input.value

    for service in services
      service.search input.value, (title, band, request) ->
        console.log "requested: #{title} by #{band}", request
        search.spotify title, band, (track) ->
          console.log "spotify found: #{track.name} by #{track.artists[0].name}", track
          return console.log "not queued - already in playlist" unless playlist.indexOf(track) < 0
          playlist.add track
          models.player.play track, playlist, 0 if !models.player.playing
          entry = document.createElement('li')
          html = "<ul class='inline'>"
          html += "<li>#{helper.image(track.image)}</li>"
          html += "<li class='track'><strong>#{track.name}</strong><br />by #{track.artists[0].name}</li>"
          html += "<li>#{helper.image(request.avatar_uri)}</li>"
          html += "<li class='user'><a href='#{request.profile_uri}'>#{request.fullname} (@#{request.username})</a></li>"
          html += "</ul>"
          results.appendChild entry
          entry.innerHTML = html
exports.init = init