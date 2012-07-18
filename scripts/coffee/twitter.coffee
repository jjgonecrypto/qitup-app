sp = getSpotifyApi 1

auth = sp.require "sp://import/scripts/api/auth"
api = sp.require "/scripts/js/service-keys"
jsOAuth = sp.require "/scripts/3rd/jsOAuth-1.3.5.min"
jsOAuth.XMLHttpRequest = XMLHttpRequest #get around jsOAuth browser limitation

xhr = undefined
oauth = undefined

tweetsByQuery = {}

authenticate = (done) ->
  twitterAPI = jsOAuth.OAuth
    consumerKey: api.twitter.consumerKey
    consumerSecret: api.twitter.consumerSecret
    authTokenKey: api.twitter.authTokenKey
    authTokenSecret: api.twitter.authTokenSecret
    callbackUrl: 'http://qitup.fm'

  twitterAPI.post 'https://api.twitter.com/oauth/request_token', {}
  , (data) -> 
    console.log "token OK: ", oauth = twitterAPI.parseTokenRequest data
    auth.showAuthenticationDialog "https://api.twitter.com/oauth/authorize?oauth_token="+oauth.oauth_token, 'http://qitup.fm', 
      onSuccess: (response) ->
        return oauth.status = false and done(null, "user access denied.") if response.indexOf("?denied=#{oauth.oauth_token}") >= 0
        oauth.status = true
        done response
      onFailure: (err) ->
        return oauth.status = false and done null, err
  , (err) -> 
    return oauth.status = false and done null, err

search = (query, next) ->
  xhr.abort() if xhr
  xhr = new XMLHttpRequest()
  xhr.open "GET", searchUri(query)
  xhr.onreadystatechange = ->
    return unless xhr.readyState is 4
    try
      data = JSON.parse(xhr.responseText)
    catch err
      return
    setLastId query, data.max_id_str
    data.results.reverse().forEach (result) ->
      console.log "tweet found: \"#{result.text.substr(0, 50)}...\" by @#{result.from_user}" 
      return console.log "cached - ignoring" if cached query, result
      tweet = result.text
      {track, artist} = match tweet
      if (track or artist) 
        next track, artist,
          username: result.from_user
          fullname: result.from_user_name
          avatar_uri: result.profile_image_url
          profile_uri: "http://twitter.com/#{result.from_user}"
          text: tweet
      else console.log "nothing matched." 
  xhr.send()  

searchUri = (query) ->
  uri = "http://search.twitter.com/search.json?q=#{query}"
  uri += "&since_id=#{tweetsByQuery[query].last_id}" if tweetsByQuery[query]?.last_id
  uri

message = (tweet, text, reply_to_id) ->
  return unless oauth.status
  console.log tweet, text

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
    str.match(new RegExp("#{field}\\s+(\"|“).+?(\"|”|$)", "i"))?[0].replace(new RegExp("^#{field}+\\s+(?=\"|“)", "i"), "") or null

  trackPrefixes = ['play','hear','listen','queue']
  artistPrefixes = ['by', 'artist', 'band']

  for trackPrefix in trackPrefixes
    break if (track = matchColonSpace trackPrefix, tweet) 
    break if (track = matchQuotes trackPrefix, tweet)

  for artistPrefix in artistPrefixes
    break if (artist = matchColonSpace artistPrefix, tweet) 
    break if (artist = matchQuotes artistPrefix, tweet)

  track: track, artist: artist 

exports.search = search
exports.reset = reset
exports.authenticate = authenticate
exports.message = message