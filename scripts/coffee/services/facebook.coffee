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

  doGenerateEndpoints: () ->
    endpoints = []
    endpoints.push  
      query: @criteria.keywords.join(",")
      uri: "#{url.search @criteria.keywords}"
    for username in @criteria.usernames
      endpoints.push 
        query: "@#{username}"
        uri: url.feed encodeURI(username) 
        authenticate: true
    @endpoints = endpoints

  extras = () ->
    [
      key: "access_token", value: @accessToken, authenticated: true
    ,  
      key: "limit", value: 100
    ,  
      key: "since", value: @lastId endpoint.uri ? null 
    ]  

  appendTo = (extras, endpoint) ->
    separator = if endpoint.uri.indexOf "?" then "&" else "?"
    uri = "#{endpoint.uri}#{separator}" 
    uri += "#{entry.key}=#{entry.value}&" for entry in extras when endpoint.value and (not endpoint.authenticate or entry.authenticated is @authenticated  )
    uri

  doSearch: (next) ->
    @ajax.search.abort() if @ajax.search
  
    for endpoint in @endpoints
      if endpoint.authenticate and not @authenticated
        console.log "cannot run facebook search for #{endpoint.query}: not authenticated" 
        continue

      uri = appendTo extras().call(@), endpoint
      #ajax
        #.done (result, request)
          #@lastId (request.uri, request.id)
          #for each result
            #next ...



    ###
    @ajax.search = ç.ajax
      uri: searchUri(request.query)
    .done (result) ->
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

    .fail (err, status) ->
      console.log "error!", err, status
      if status is 400 and err.error.code is 190 and err.error.error_subcode is 463
        console.log "facebook auth expired. automatically reauthing.", err.error
        api.status = false
        authenticate (response, err) ->
          return console.log err if err
          return search request, next
      else if status is 400 and err.error.code is 190
        api.status = false
        onExpired(err, status) if onExpired
        return console.log "facebook request returned a 400 (fbook code 190)", err
      else
        return console.log "facebook request returned a #{status}", err  
      ###

exports.Facebook = Facebook 