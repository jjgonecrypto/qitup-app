sp = getSpotifyApi 1

auth = sp.require "sp://import/scripts/api/auth"
keys = sp.require "/scripts/js/service-keys"
helper = sp.require "/scripts/js/helper"
ç = sp.require("/scripts/js/swah").swah

Service = sp.require("/scripts/js/service").Service

class Facebook extends Service

  url =
    search: "https://graph.facebook.com/search"
    picture: (id) -> "https://graph.facebook.com/#{id}/picture"
    feed: (username) -> "https://graph.facebook.com/#{username}/feed"
    comment: (id) -> "https://graph.facebook.com/#{id}/comments"
    logout: "https://www.facebook.com/logout.php?next=http://qitup.fm"
  
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
      uri: "#{url.logout}&access_token=#{@accessToken}" 
    .done (result) ->
      done() if done
    .fail (err, status) ->
      done err if done

  doMessage: (post, text, done) ->
    #todo
    done()

  doSearch: (next) ->
    #todo
    next()

exports.Facebook = Facebook 