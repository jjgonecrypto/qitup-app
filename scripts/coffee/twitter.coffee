sp = getSpotifyApi 1

auth = sp.require "sp://import/scripts/api/auth"
keys = sp.require "/scripts/js/service-keys"
jsOAuth = sp.require "/scripts/3rd/jsOAuth-1.3.5"
jsOAuth.XMLHttpRequest = XMLHttpRequest #get around jsOAuth browser limitation

xhr = undefined
api = undefined

tweetsByQuery = {}

parseUri = (uri, key) ->
  uri.match(new RegExp("#{key}=.+?(?=$|&)"))?[0].substr("#{key}=".length) ? console.log("no match for #{key}!")

authenticate = (done) ->
  oauth = undefined

  api = jsOAuth.OAuth
    consumerKey: keys.twitter.consumerKey
    consumerSecret: keys.twitter.consumerSecret
    authTokenKey: keys.twitter.authTokenKey
    authTokenSecret: keys.twitter.authTokenSecret
    callbackUrl: 'http://qitup.fm'

  result = (response, err) ->
    api.status = response? and (err is undefined or err is null)
    done response, err

  api.post 'https://api.twitter.com/oauth/request_token', {}
  , (data) -> 
    console.log "token OK."
    oauth = api.parseTokenRequest data
    auth.showAuthenticationDialog "https://api.twitter.com/oauth/authorize?oauth_token="+oauth.oauth_token, 'http://qitup.fm', 
      onSuccess: (response) ->
        if response.indexOf("?denied=#{oauth.oauth_token}") >= 0 
          api.status = false
          return done(null, "user access denied.") 
        api.setAccessToken oauth.oauth_token, oauth.oauth_token_secret
        api.post "https://api.twitter.com/oauth/access_token",
          oauth_verifier: parseUri response, "oauth_verifier"
        , (data) ->
          console.log "twitter authenticated."
          api.setAccessToken parseUri(data.text, "oauth_token"), parseUri(data.text, "oauth_token_secret")
          result 
            user_id: parseUri(data.text, "user_id")
            screen_name: parseUri(data.text, "screen_name")
        , (err) ->
          result null, err
      onFailure: (err) ->
        result null, err
  , (err) -> 
    result null, err

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
          id: result.id_str
      else console.log "nothing matched." 
  xhr.send()  

searchUri = (query) ->
  uri = "http://search.twitter.com/search.json?q=#{query}"
  uri += "&since_id=#{tweetsByQuery[query].last_id}" if tweetsByQuery[query]?.last_id
  uri

logged_in = () -> api.status is true

message = (tweet, text, done) ->
  return console.log "no twitterauth" unless api?.status
  console.log tweet, text
  api.post "https://api.twitter.com/1/statuses/update.json", 
    status: "@#{tweet.username} #{text}"
    in_reply_to_status_id: tweet.id
  , (data) ->
    console.log "tweet sent successfully."
    done null, data if done
  , (err) ->
    console.log "error tweeting", err
    done err if done

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
exports.logged_in = logged_in
exports.message = message