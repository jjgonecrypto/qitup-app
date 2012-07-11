xhr = undefined
tweetsByQuery = {}

search = (query, next) ->
  xhr.abort() if xhr
  xhr = new XMLHttpRequest()
  xhr.open "GET", searchUri(query)
  xhr.onreadystatechange = ->
    return unless xhr.readyState is 4
    data = JSON.parse(xhr.responseText)
    setLastId query, data.max_id_str
    data.results.forEach (result) ->
      return if cached query, result
      tweet = result.text
      {track, artist} = match tweet
      next track, artist, result.from_user, result.profile_image_url, result.from_user_name
      , "http://twitter.com/#{result.from_user}" if (track) 
  xhr.send()  

searchUri = (query) ->
  uri = "http://search.twitter.com/search.json?q=#{query}"
  uri += "&since_id=#{tweetsByQuery[query].last_id}" if tweetsByQuery[query]?.last_id
  uri

setLastId = (query, last_id) ->
  initCacheFor query
  tweetsByQuery[query]?.last_id = last_id

cached = (query, tweet) -> 
  initCacheFor query 
  status = tweetsByQuery[query][tweet.id]?
  tweetsByQuery[query][tweet.id]?= tweet
  status

initCacheFor = (query) -> tweetsByQuery[query]?= {}

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