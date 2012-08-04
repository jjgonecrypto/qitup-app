regexORList = (array) ->
  array.map((a) -> "#{a}\\s").join("|").replace(/\s/g,"\\s")

matchColonSpace = (field, str) ->
  str.match(new RegExp("(?=#{field}:).+?(?=\\s|$)", "i"))?[0].substr(field.length + 1) or null

matchQuotes = (field, str) ->
  str.match(new RegExp("#{field}\\s+(\"|“).+?(\"|”|$)", "i"))?[0].replace(new RegExp("^#{field}+\\s+(?=\"|“)", "i"), "") or null

matchHasKeyword = (before, targets, str) ->
  str.match(new RegExp("(#{regexORList(before)})(#{regexORList(targets)})", "i"))?[0]?

match = (text, done) ->

  trackPrefixes = ['play','hear','listen','queue']
  artistPrefixes = ['by', 'artist', 'band']
  randomPrefixes = ['anything', 'something']

  for trackPrefix in trackPrefixes
    break if (track = matchColonSpace trackPrefix, text) 
    break if (track = matchQuotes trackPrefix, text)

  for artistPrefix in artistPrefixes
    break if (artist = matchColonSpace artistPrefix, text) 
    break if (artist = matchQuotes artistPrefix, text)

  random = matchHasKeyword trackPrefixes, randomPrefixes, text

  if track or artist
    done
      track: track
      artist: artist
      random: random 
  else
    done()

exports.match = match