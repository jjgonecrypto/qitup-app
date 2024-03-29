regexORList = (array) ->
  array.join("|").replace(/\s/g,"\\s")

matchColonSpace = (before, str) ->
  str.match(new RegExp("(#{regexORList(before)})\\:.+?(?=\\s|$)", "i"))?[0].replace(new RegExp("^(#{regexORList(before)})\\:", "i"), "") or null

matchQuotes = (before, str) ->
  str.match(new RegExp("(#{regexORList(before)})\\s+(\"|“).+?(\"|”|$)", "i"))?[0].replace(new RegExp("^(#{regexORList(before)})\\s+(?=\"|“)", "i"), "") or null

matchHasKeyword = (before, targets, str) ->
  str.match(new RegExp("(#{regexORList(before)})\\s+(#{regexORList(targets)})\\s+", "i"))?[0]?

match = (text, done) ->
  trackPrefixes   = ['play','hear','listen','queue']
  artistPrefixes  = ['by', 'artist', 'band']
  albumPrefixes   = ['from', 'off']
  randomPrefixes  = ['anything', 'something', '\\*']

  track = matchQuotes(trackPrefixes, text) ? matchColonSpace(trackPrefixes, text)
  artist = matchQuotes(artistPrefixes, text) ? matchColonSpace(artistPrefixes, text)
  album = matchQuotes(albumPrefixes, text) ? matchColonSpace(albumPrefixes, text)

  random = matchHasKeyword trackPrefixes, randomPrefixes, text

  if track or artist or album
    done
      track: track
      artist: artist
      album: album
      random: random 
  else
    done()

exports.match = match