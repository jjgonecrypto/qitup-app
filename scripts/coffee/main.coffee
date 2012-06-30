sp = getSpotifyApi 1

models = sp.require "sp://import/scripts/api/models"

helper = sp.require "/scripts/js/helper"
twitter = sp.require "/scripts/js/twitter"
search = sp.require "/scripts/js/search"
services = [twitter]


init = ->

  query = document.getElementById "query"
  searchBtn = document.getElementById "search"
  status = document.getElementById "details"
  searchBtn.addEventListener "click", ->
    html = ""
    status.innerHTML = ""
    playlist = new models.Playlist()

    for service in services
      service.search query.value, (title, band, username, avatar_uri, fullname, profile_uri) ->
        search.spotify title, band, (track) ->
          return unless playlist.indexOf(track) < 0
          playlist.add track
          models.player.play track, playlist, 0 if playlist.length is 1
          html += "<li><ul class='inline'>"
          html += "<li>#{helper.image(track.image)}</li>"
          html += "<li class='track'><strong>#{track.name}</strong><br />by #{track.artists[0].name}</li>"
          html += "<li>#{helper.image(avatar_uri)}</li>"
          html += "<li class='user'><a href='{$profile_uri}'>#{fullname} (@#{username})</a></li>"
          html += "</ul></li>"
          status.innerHTML = "<ul class='results'>" + html + "</ul>"

exports.init = init