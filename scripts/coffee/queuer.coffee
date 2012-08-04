sp = getSpotifyApi 1

search = sp.require "/scripts/js/search"


queue = undefined
timeout = undefined
reset_flag = false

reset = () ->
  reset_flag = true
  clearTimeout timeout if timeout
  queue = []
  #start timeout of process

add = (match, request, callback) ->
  queue.push 
    match: match
    request: request 
    callback: callback
  reset_flag = false
  process()

poll = () -> 
  return reset_flag = false if reset_flag
  timeout = setTimeout (() -> process()), 1000

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