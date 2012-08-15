sp = getSpotifyApi 1

auth = sp.require "sp://import/scripts/api/auth"
keys = sp.require "/scripts/js/service-keys"
helper = sp.require "/scripts/js/helper"

jsOAuth = sp.require "/scripts/3rd/jsOAuth-1.3.5"
jsOAuth.XMLHttpRequest = XMLHttpRequest #get around jsOAuth browser limitation

url = 
  search: "https://graph.facebook.com/search"
  picture: (id) -> "https://graph.facebook.com/#{id}/picture"
  feed: (username) -> "https://graph.facebook.com/#{username}/feed"
  comment: (id) -> "https://graph.facebook.com/#{id}/comments"

xhr = undefined
xhr2 = undefined
xhr3 = undefined

api = {}

permissions = ['manage_pages', 'publish_stream']
postsByQuery = {}
ignorePosts = []
onExpired = undefined

authenticate = (done, expired) ->
  onExpired = expired if expired instanceof Function
  result = (response, err) ->
    api.status = response? and (err is undefined or err is null)
    api.accessToken = response
    done response, err

  auth.authenticateWithFacebook keys.facebook.appID, permissions, 
    onSuccess: (accessToken, ttl) ->
      console.log "Facebook auth successful!", accessToken, ttl
      result accessToken

    onFailure: (error) -> 
      console.log 'Facebook authentication failed', error
      result null, errs

signout = (done) ->
  xhr3.abort() if xhr3
  xhr3 = new XMLHttpRequest()
  xhr3.open "GET", "https://www.facebook.com/logout.php?next=http://qitup.fm" + "&access_token=#{api.accessToken}" 
  xhr3.onreadystatechange = ->
    return unless xhr3.readyState is 4
    api.status = false
    done() if done
  xhr3.send()

search = (request, next) ->
  return console.log "cannot search fbook without auth" unless api.status

  xhr.abort() if xhr
  xhr = new XMLHttpRequest()
  uri = "#{url.feed(request.query)}?access_token=#{api.accessToken}&limit=100"
  uri += "&since=#{postsByQuery[request.query].last_id}" if postsByQuery[request.query]?.last_id
  xhr.open "GET", uri
  service = @

  strip = (text, query) ->
    if query.match(/[^a-zA-Z0-9-_]/g)
      query = query.replace /[^a-zA-Z0-9-_]/g, (found) -> "\\#{found}"
      text.replace(new RegExp(query, "gi"), "")
    else
      text #dont strip keyword searches (no easy way to tell if within pattern)

  xhr.onreadystatechange = ->
    return unless xhr.readyState is 4
    try
      result = JSON.parse(xhr.responseText)
    catch err
      return console.log "couldn't parse response from Facebook.", err, xhr

    if xhr.status is 400 and result.error.code is 190 and result.error.error_subcode is 463
      console.log "facebook auth expired. automatically reauthing.", result.error
      api.status = false
      authenticate (response, err) ->
        return console.log err if err
        return search request, next

    if xhr.status != 200
      api.status = false
      onExpired(result, xhr.status) if onExpired
      return console.log "facebook request returned a #{xhr.status}", result
      
    return unless result.data.length > 0

    setLastId request.query, helper.parseUri(result.paging.previous, "since")
    result.data.reverse().forEach (entry) ->
      return unless entry.message and entry.id
      console.log "facebook post found: \"#{entry.message.substr(0, 50)}...\" by @#{entry.from.name}" 
      return console.log "cached - ignoring" if cached request.query, entry
      return console.log "past - ignoring" if request.from_date and new Date(entry.created_time) < request.from_date
      return console.log "self-message - ignoring" unless ignorePosts.indexOf(entry.id) is -1

      next 
        username: entry.from.name
        fullname: entry.from.name
        avatar_uri: url.picture(entry.from.id)
        profile_uri: "http://facebook.com/#{entry.from.id}"
        stripped: strip entry.message, request.query
        text: entry.message
        id: entry.id
      , service

  xhr.send()  

###
searchUri = (query) ->
  uri = "#{url.search}?limit=100&q=#{encodeURIComponent(query)}"
  uri += "&since=#{postsByQuery[query].last_id}" if postsByQuery[query]?.last_id
  uri
###
logged_in = () -> api.status is true



message = (post, text, done) ->

  xhr2.abort() if xhr2
  xhr2 = new XMLHttpRequest()
  xhr2.open "GET", url.comment(post.id) + "?access_token=#{api.accessToken}&method=post&format=json&message=#{encodeURIComponent(text)}" 
  xhr2.onreadystatechange = ->
    return unless xhr2.readyState is 4
    done() if done
  xhr2.send()

setLastId = (query, last_id) ->
  initCacheFor query
  postsByQuery[query]?.last_id = last_id

cached = (query, post) -> 
  initCacheFor query 
  status = postsByQuery[query][post.id]?
  postsByQuery[query][post.id]?= post
  status

initCacheFor = (query) -> postsByQuery[query]?= {}

reset = -> 
  xhr.abort() if xhr
  xhr = null
  postsByQuery = {}
  ignorePosts = []
  api = {}

exports.search = search
exports.reset = reset
exports.authenticate = authenticate
exports.signout = signout
exports.logged_in = logged_in
exports.message = message