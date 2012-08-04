sp = getSpotifyApi 1

auth = sp.require "sp://import/scripts/api/auth"
keys = sp.require "/scripts/js/service-keys"
jsOAuth = sp.require "/scripts/3rd/jsOAuth-1.3.5"
jsOAuth.XMLHttpRequest = XMLHttpRequest #get around jsOAuth browser limitation

url = 
  request: "https://api.twitter.com/oauth/request_token"
  auth: "https://api.twitter.com/oauth/authorize"
  access: "https://api.twitter.com/oauth/access_token"
  signout: "https://api.twitter.com/1/account/end_session.json"
  search: "http://search.twitter.com/search.json"
  message: "https://api.twitter.com/1/statuses/update.json"
  
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
    callbackUrl: 'http://qitup.fm'

  result = (response, err) ->
    api.status = response? and (err is undefined or err is null)
    done response, err

  api.post url.request, {}
  , (data) -> 
    console.log "token OK."
    oauth = api.parseTokenRequest data
    auth.showAuthenticationDialog "#{url.auth}?oauth_token="+oauth.oauth_token, 'http://qitup.fm', 
      onSuccess: (response) ->
        if response.indexOf("?denied=#{oauth.oauth_token}") >= 0 
          api.status = false
          return done(null, "user access denied.") 
        api.setAccessToken oauth.oauth_token, oauth.oauth_token_secret
        api.post url.access,
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

signout = (done) ->
  return done() unless api?.status
  api.post url.signout, {}
  , (data) ->
    console.log "logged out of Twitter successfully."
    api.status = false
    done()
  , (err) ->
    console.log "error logging out of Twitter", err
    done err

search = (search, next) ->
  xhr.abort() if xhr
  xhr = new XMLHttpRequest()
  xhr.open "GET", searchUri(search.query)

  strip = (text, query) ->
    if query.match(/[^a-zA-Z0-9-_]/g)
      query = query.replace /[^a-zA-Z0-9-_]/g, (found) -> "\\#{found}"
      text.replace(new RegExp(query, "gi"), "")
    else
      text #dont strip keyword searches (no easy way to tell if within pattern)

  xhr.onreadystatechange = ->
    return unless xhr.readyState is 4
    try
      data = JSON.parse(xhr.responseText)
    catch err
      return
    setLastId search.query, data.max_id_str
    data.results.reverse().forEach (result) ->
      console.log "tweet found: \"#{result.text.substr(0, 50)}...\" by @#{result.from_user}" 
      return console.log "cached - ignoring" if cached search.query, result
      return console.log "past - ignoring" if search.from_date and new Date(result.created_at) < search.from_date
      
      next 
        username: result.from_user
        fullname: result.from_user_name
        avatar_uri: result.profile_image_url
        profile_uri: "http://twitter.com/#{result.from_user}"
        stripped: strip result.text, search.query
        text: result.text
        id: result.id_str

  xhr.send()  

searchUri = (query) ->
  uri = "#{url.search}?rpp=100&q=#{encodeURIComponent(query)}"
  uri += "&since_id=#{tweetsByQuery[query].last_id}" if tweetsByQuery[query]?.last_id
  uri

logged_in = () -> api.status is true

message = (tweet, text, done) ->
  return console.log "no twitterauth" unless api?.status
  console.log tweet, text
  api.post url.message, 
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

exports.search = search
exports.reset = reset
exports.authenticate = authenticate
exports.logged_in = logged_in
exports.message = message
exports.signout = signout