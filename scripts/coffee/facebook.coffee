sp = getSpotifyApi 1

auth = sp.require "sp://import/scripts/api/auth"
#keys = sp.require "/scripts/js/service-keys"
helper = sp.require "/scripts/js/helper"

jsOAuth = sp.require "/scripts/3rd/jsOAuth-1.3.5"
jsOAuth.XMLHttpRequest = XMLHttpRequest #get around jsOAuth browser limitation

url = 
  search: "https://graph.facebook.com/search"
  picture: (id) -> "https://graph.facebook.com/#{id}/picture"

xhr = undefined
api = undefined

postsByQuery = {}
ignorePosts = []

authenticate = (done) ->
  throw "not implemented"
  #todo

signout = (done) ->
  throw "not implemented"
  #todo

search = (search, next) ->
  xhr.abort() if xhr
  xhr = new XMLHttpRequest()
  xhr.open "GET", searchUri(search.query)
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
      return
    setLastId search.query, helper.parseUri(result.paging.previous, "since")
    result.data.reverse().forEach (entry) ->
      console.log "facebook post found: \"#{entry.message.substr(0, 50)}...\" by @#{entry.from.name}" 
      return console.log "cached - ignoring" if cached search.query, entry
      return console.log "past - ignoring" if search.from_date and new Date(entry.created_time) < search.from_date
      return console.log "self-message - ignoring" unless ignorePosts.indexOf(entry.id) is -1

      next 
        username: entry.from.name
        fullname: entry.from.name
        avatar_uri: url.picture(entry.from.id)
        profile_uri: "http://facebook.com/#{entry.from.id}"
        stripped: strip entry.message, search.query
        text: entry.message
        id: entry.id
      , service

  xhr.send()  

searchUri = (query) ->
  uri = "#{url.search}?limit=100&q=#{encodeURIComponent(query)}"
  uri += "&since=#{postsByQuery[query].last_id}" if postsByQuery[query]?.last_id
  uri

logged_in = () -> api.status is true

message = (post, text, done) ->
  console.log "facebook.message: not implemented"
  done()
  #todo

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

exports.search = search
exports.reset = reset