sp = getSpotifyApi 1

search = sp.require "/scripts/js/search"

queue = []
timeout = undefined
run = on

reset = () ->
  clearTimeout timeout if timeout
  queue = []

turn = (state) -> 
  run = state
  clearTimeout timeout if timeout
  poll() if run 

add = (match, request, callback) ->
  queue.push 
    match: match
    request: request 
    callback: callback

poll = () -> 
  return if !run
  timeout = setTimeout (() -> process()), 5000 #5s poll of queue

process = -> 
  entry = queue.shift()
  
  return poll() unless entry 

  search.spotify entry.match.track, entry.match.artist, entry.match.random, (track, notFound, err) ->
    if err 
      queue.unshift(entry)
      console.log("error so trying again")
    else
      entry.callback track, notFound

    poll()

exports.add = add
exports.reset = reset
exports.turn = turn