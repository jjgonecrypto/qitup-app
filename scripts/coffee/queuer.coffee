sp = getSpotifyApi 1

search = sp.require "/scripts/js/search"

queue = []
timeout = undefined
run = on
interval = 1000

reset = () ->
  clearTimeout timeout if timeout
  queue = []

turn = (state, ms) -> 
  run = state
  interval = ms if !isNaN ms
  clearTimeout timeout if timeout
  poll() if run 

add = (match, request, callback) ->
  queue.push 
    match: match
    request: request 
    callback: callback

getLength = () -> queue.length

poll = () -> 
  return if !run
  timeout = setTimeout (() -> process()), interval

process = -> 
  entry = queue.shift()
  
  return poll() unless entry 

  search.spotify entry.match.track, entry.match.artist, entry.match.album, entry.match.random, (track, notFound, err) ->
    if err 
      queue.unshift(entry)
      console.log("error so trying again")
    else
      entry.callback track, notFound

    poll()

exports.add = add
exports.reset = reset
exports.turn = turn
exports.getLength = getLength