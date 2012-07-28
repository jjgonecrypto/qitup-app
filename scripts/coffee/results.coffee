sp = getSpotifyApi 1

templator = sp.require "/scripts/js/templator"
helper = sp.require "/scripts/js/helper"

add = (track, artist, request) ->
  html = templator.process "/views/results.html", 
    track: track
    artist: artist
    request: request
    helper: helper

  return html  

exports.add = add