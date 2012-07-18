sp = getSpotifyApi 1

models = sp.require "sp://import/scripts/api/models"
auth = sp.require "sp://import/scripts/api/auth"
jsOAuth = sp.require "/scripts/3rd/jsOAuth-1.3.5.min"
jsOAuth.XMLHttpRequest = XMLHttpRequest #get around jsOAuth browser limitation
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
  oauth = undefined

  searchBtn.addEventListener "click", ->
    clearInterval interval if interval
    interval = setInterval searchServices, 30*1000
    searchServices()
    toggle on

  stopBtn.addEventListener "click", ->
    clearInterval interval if interval
    toggle off

  twitterBtn.addEventListener "click", ->

    twitterAuth = jsOAuth.OAuth
      consumerKey: twitter.api.consumerKey
      consumerSecret: twitter.api.consumerSecret
      authTokenKey: twitter.api.authTokenKey
      authTokenSecret: twitter.api.authTokenSecret
      callbackUrl: 'http://qitup.fm'
    
    twitterAuth.post 'https://api.twitter.com/oauth/request_token', {}
    , (data) -> 
      console.log "token OK: ", oauth = twitterAuth.parseTokenRequest data
      auth.showAuthenticationDialog "https://api.twitter.com/oauth/authorize?oauth_token="+oauth.oauth_token, 'http://qitup.fm', 
        onSuccess: (response) ->
          return console.log "denied " if response.indexOf("?denied=#{oauth.oauth_token}") >= 0
          console.log "success: ", response
        onFailure: (error) ->
          console.log "error: ", error
        onComplete: () ->
          console.log "done"
    , (err) -> 
      console.log "err ", err

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
        search.spotify title, band, (track) ->
          console.log "spotify found: #{track.name} by #{track.artists[0].name}", track
          return console.log "not queued - already in playlist" unless playlist.indexOf(track) < 0
          playlist.add(track) and playlistToSave.add(track)
          models.player.play track, playlist, position++ if !models.player.playing and position is 0
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