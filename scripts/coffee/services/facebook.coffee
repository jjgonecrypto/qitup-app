sp = getSpotifyApi 1

auth = sp.require "sp://import/scripts/api/auth"
keys = sp.require "/scripts/js/service-keys"
helper = sp.require "/scripts/js/helper"
ç = sp.require("/scripts/js/swah").swah

Service = sp.require("/scripts/js/service").Service

class Facebook extends Service

  url =
    search: (keywords) -> "https://graph.facebook.com/search?q=#{keywords.map((item) -> encodeURI(item)).join("+OR+")}"
    picture: (id) -> "https://graph.facebook.com/#{id}/picture"
    feed: (username) -> "https://graph.facebook.com/#{encodeURI(username)}/feed"
    comment: (id) -> "https://graph.facebook.com/#{id}/comments"
    logout: (accessToken) -> "https://www.facebook.com/logout.php?next=#{encodeURI('http://qitup.fm')}&access_token=#{accessToken}"
  
  permissions = ['manage_pages', 'publish_stream'] 

  constructor: (@ajax = {}) -> super()
  
  doAuthenticate: (done) ->
    auth.authenticateWithFacebook keys.facebook.appID, permissions, 
      onSuccess: (accessToken, ttl) =>
        console.log "Facebook auth successful!", accessToken, ttl
        @accessToken = accessToken
        done accessToken

      onFailure: (error) => 
        console.log 'Facebook authentication failed', error
        done null, error
 
  doLogout: (done) ->
    @ajax.logout.abort() if @ajax.logout   
    @ajax.logout = ç.ajax
      uri: url.logout @accessToken 
    .done (result) ->
      done() if done
    .fail (err, status) ->
      done err if done

  doMessage: (post, text, done) ->
    #todo
    done()

  doGenerateEndpointsFrom: (criteria) ->
    endpoints = []
    endpoints.push  
      query: criteria.keywords.join(",")
      strip: criteria.keywords
      uri: "#{url.search criteria.keywords}"
    for username in criteria.usernames
      endpoints.push 
        query: "@#{username}"
        strip: username
        uri: url.feed encodeURI(username) 
        authenticate: true
    @endpoints = endpoints

  extras = (endpoint) ->
    [
      key: "access_token", value: @accessToken, authenticated: true
    ,  
      key: "limit", value: 100
    ,  
      key: "since", value: @lastId endpoint.uri ? null 
    ]  

  appendTo = (extras, endpoint) ->
    separator = if endpoint.uri.indexOf("?") > 0 then "&" else "?"
    uri = "#{endpoint.uri}#{separator}" 
    uri += "#{entry.key}=#{entry.value}&" for entry in extras when endpoint.value and (not endpoint.authenticate or entry.authenticated is @authenticated  )
    uri

  strip = (text, toStrip) ->
    toStrip = [toStrip] if toStrip instanceof String
    for query in toStrip
      if query.match(/[^a-zA-Z0-9-_]/g)
        query = query.replace /[^a-zA-Z0-9-_]/g, (found) -> "\\#{found}"
        text.replace(new RegExp(query, "gi"), "")
      #else: dont strip keyword searches (no easy way to tell if within pattern)
    text
  

  callEndpoint = (endpoint, next) ->
    if endpoint.authenticate and not @authenticated
      return console.log "cannot run facebook search for #{endpoint.query}: not authenticated" 
    
    @ajax[endpoint.uri].abort() if @ajax[endpoint.uri] 

    @ajax[endpoint.uri] = ç.ajax
      uri: appendTo extras.call(@, endpoint), endpoint
    .done (result, status, request) =>
      @lastId endpoint.uri, helper.parseUri(result.paging.previous, "since")
      result.data.reverse().forEach (entry) ->
        return unless entry.message and entry.id
        console.log "facebook post found: \"#{entry.message.substr(0, 50)}...\" by @#{entry.from.name}" 
        
        next 
          username: entry.from.name
          fullname: entry.from.name
          avatar_uri: url.picture(entry.from.id)
          profile_uri: "http://facebook.com/#{entry.from.id}"
          stripped: strip entry.message, endpoint.strip
          text: entry.message
          id: entry.id

    .fail (err, status) ->
      console.log "facebook search error!", err, status

  doSearch: (next) ->
    callEndpoint.call @, endpoint, next for endpoint in @endpoints


exports.Facebook = Facebook 