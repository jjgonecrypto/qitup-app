###
matchColonSpace = (field, str) ->
  str.match(new RegExp("(?=#{field}:).+?(?=\\s|$)", "i"))?[0].substr(field.length + 1) or null

matchQuotes = (field, str) ->
  str.match(new RegExp("#{field}\\s+(\"|“).+?(\"|”|$)", "i"))?[0].replace(new RegExp("^#{field}+\\s+(?=\"|“)", "i"), "") or null
###

trackPrefixes = ['play','hear','listen to','queue up']
artistPrefixes = trackPrefixes.concat ['by', 'artist', 'band']
albumPrefixes = ['from', 'off']
randomKeywords = ['random','anything','something']

regexORList = (array) ->
  array.map((a) -> "#{a}\\s").join("|").replace(/\s/g,"\\s")

matchFromKeywords = (text, fromKeywords, toKeywords, callback) ->
  callback = if toKeywords instanceof Function then toKeywords else callback
  lookahead = if toKeywords instanceof Array then "(?=#{regexORList(toKeywords)}|$)" else "$"
  lookbehind = if fromKeywords instanceof Array then "(?=#{regexORList(fromKeywords)})" else "^"
  found = undefined
  remainder = text.replace new RegExp("#{lookbehind}.+?#{lookahead}"), (token) ->
    token = token.replace(new RegExp("^#{regexORList(fromKeywords)}"), () -> "").trim() if fromKeywords instanceof Array
    found = if token is "" then null else token
    ""
  callback(found, remainder)

matchAll = (text) ->
  trackRes = matchFromKeywords text, trackPrefixes, artistPrefixes.concat(albumPrefixes) 
  artistRes = matchFromKeywords trackRes.cleaned, artistPrefixes, trackPrefixes.concat(albumPrefixes)
  albumRes = matchFromKeywords artistRes.cleaned, albumPrefixes, artistPrefixes.concat(trackPrefixes)

  result =  
    track: trackRes.found
    artist: artistRes.found
    album: albumRes.found
    random: randomKeywords.indexOf(trackRes.found.toLowerCase()) >= 0 #potential for 

appendIfNotExists = (array, el) ->
  return if array.filter((item) -> JSON.stringify(item) is JSON.stringify(el)).length > 0
  return if Object.keys(el).length is 0  
  array.push el

matchRecurse = (text) ->
  result = []

  matchFromKeywords text, trackPrefixes, artistPrefixes.concat(albumPrefixes), (track, remainder) ->
    matchFromKeywords remainder, artistPrefixes, trackPrefixes.concat(albumPrefixes), (artist, remainder) ->
      matchFromKeywords remainder, albumPrefixes, artistPrefixes.concat(trackPrefixes), (album) ->
        appendIfNotExists result, {track: track, artist: artist, album: album} 

  matchFromKeywords text, trackPrefixes, artistPrefixes, (track, remainder) ->
    matchFromKeywords remainder, artistPrefixes, albumPrefixes, (artist, remainder) ->
      matchFromKeywords remainder, albumPrefixes, trackPrefixes, (album, remainder) ->
        appendIfNotExists result, {track: track, artist: artist, album: album} 

  matchFromKeywords text, trackPrefixes, albumPrefixes, (track, remainder) ->
    matchFromKeywords remainder, artistPrefixes, trackPrefixes, (artist, remainder) ->
      matchFromKeywords remainder, albumPrefixes, artistPrefixes, (album, remainder) ->
        appendIfNotExists result, {track: track, artist: artist, album: album} 

  matchFromKeywords text, trackPrefixes, (track, remainder) ->
    appendIfNotExists result, {track: track} 

  #eg. beginning to artist `1979 by the smashing pumpkins`  
  matchFromKeywords text, null, artistPrefixes, (track, remainder) -> 
    matchFromKeywords text, artistPrefixes, (artist, remainder) ->
      appendIfNotExists result, {track: track, artist: artist} 
    
    
    
  matchFromKeywords text, artistPrefixes, (artist, remainder) ->
    appendIfNotExists result, {artist: artist} 

  matchFromKeywords text, albumPrefixes, (album, remainder) ->
    appendIfNotExists result, {album: album}   

  matchFromKeywords text, null, (any, remainder) ->
    appendIfNotExists result, {any: any}

  result



match = (text, callback) ->

  results = [] 

  #track keyword, artist keyword, album keyword 
  #results.push matchAll(text)

  #track keyword to end (eg. `play stand by me` => track: 'stand by me')
  #results.push matchFromKeywords(text, trackPrefixes)

  #artist keyword to end (eg. `by nirvana`)

  #full track search
  results.push track: text
  #full artist search
  results.push artist: text
  #full album search
  results.push album: text 

  #track keyword to end
  results.push matchKeywordToEnd trackPrefixes, text

  

  #artist keyword to end
  results.push matchKeywordToEnd artistPrefixes, text

  #album keyword to end
  #anything keyword, [artist keyword], [album keyword]


  #return array of requests
  ###
  callback
    [
      track: ...
      artist: ...
      album: ...
      random: ...
    ]
  ###
  callback()

exports.match = match  