xhr = undefined
tweetsByQuery = {}

search = (query, next) ->
  xhr.abort() if xhr
  xhr = new XMLHttpRequest()
  xhr.open "GET", "http://search.twitter.com/search.json?q=" + query
  xhr.onreadystatechange = ->
    return unless xhr.readyState is 4
    data = JSON.parse(xhr.responseText)
    data.results.forEach (result) ->
      return if cached query, result
      tweet = result.text
      {track, artist} = match tweet
      if (track) 
        next track, artist,
          username: result.from_user_name
          name: result.from_user
          avatar_uri: result.profile_image_url
          profile_uri: "http://twitter.com/#{result.from_user}" 
  xhr.send()  

cached = (query, tweet) -> 
  tweetsByQuery[query]?= {}
  status = tweetsByQuery[query][tweet.id]?
  tweetsByQuery[query][tweet.id]?= tweet
  status

reset = -> 
  xhr.abort() if xhr
  xhr = null
  tweetsByQuery = {}

match = (tweet) ->

  matchColonSpace = (field, str) ->
    str.match(new RegExp("(?=#{field}:).+?(?=\\s|$)", "i"))?[0].substr(field.length + 1) or null

  matchQuotes = (field, str) ->
    str.match(new RegExp("#{field}\\s\".+?\"|$", "i"))?[0].substr(field.length + 1) or null

  trackPrefixes = ['play','hear','listen','queue']
  artistPrefixes = ['by', 'artist', 'band']

  for trackPrefix in trackPrefixes
    break if (track = matchColonSpace trackPrefix, tweet) 
    break if (track = matchQuotes trackPrefix, tweet)
  return {track: null, artist: null} if !track

  for artistPrefix in artistPrefixes
    break if (artist = matchColonSpace artistPrefix, tweet) 
    break if (artist = matchQuotes artistPrefix, tweet)

  track: track, artist: artist 

exports.search = search
exports.reset = reset