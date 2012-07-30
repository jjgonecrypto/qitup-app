sp = getSpotifyApi 1

templator = sp.require "/scripts/js/templator"
helper = sp.require "/scripts/js/helper"

found = (track, artist, request) ->
  templator.process "/views/result-found.html", 
    track: track
    artist: artist
    request: request
    helper: helper

notFound = (searchStr, request) ->
  templator.process "/views/result-notfound.html", 
    searchStr: searchStr
    request: request
    helper: helper

exports.found = found
exports.notFound = notFound