sp = getSpotifyApi 1

auth = sp.require "sp://import/scripts/api/auth"
keys = sp.require "/scripts/js/service-keys"
helper = sp.require "/scripts/js/helper"

Service = sp.require "/scripts/js/service"

class Facebook extends Service

  url:
    search: "https://graph.facebook.com/search"
    picture: (id) -> "https://graph.facebook.com/#{id}/picture"
    feed: (username) -> "https://graph.facebook.com/#{username}/feed"
    comment: (id) -> "https://graph.facebook.com/#{id}/comments"
    logout: "https://www.facebook.com/logout.php?next=http://qitup.fm"

  ajax: {}
  permissions: ['manage_pages', 'publish_stream'] 

  doAuthenticate: (done) ->
    auth.authenticateWithFacebook keys.facebook.appID, permissions, 
      onSuccess: (accessToken, ttl) ->
        console.log "Facebook auth successful!", accessToken, ttl
        @accessToken = accessToken
        done accessToken

      onFailure: (error) -> 
        console.log 'Facebook authentication failed', error
        done null, error
 

exports.Facebook = Facebook 