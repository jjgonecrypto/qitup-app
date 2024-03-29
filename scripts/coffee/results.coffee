sp = getSpotifyApi 1

templator = sp.require "/scripts/js/templator"
helper = sp.require "/scripts/js/helper"

queued = (track, artist, album, request) ->
  templator.process "/views/result-queued.html", 
    track: track
    artist: artist
    album: album
    request: request
    helper: helper

notQueued = (reason, request) ->
  templator.process "/views/result-notqueued.html", 
    reason: reason
    request: request
    helper: helper

exports.queued = queued
exports.notQueued = notQueued