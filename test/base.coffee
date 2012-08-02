init = () ->
  should = require "should"
  sinon = require "sinon"

  auth = {}
  views = {}
  models = 
    EVENT: {}
    session: 
      observe: () ->

  global.getSpotifyApi = () -> 
    require: (module) -> 
      return require "../#{module}" unless (module.indexOf "sp://") is 0
      if module is "sp://import/scripts/api/models" 
        models 
      else if module is "sp://import/scripts/api/auth"
        auth
      else if module is "sp://import/scripts/api/views"
        views
      else console.log "cannot require #{module}"
  global.XMLHttpRequest = () ->

  result = 
    should: should
    sinon: sinon 
    models: models
    auth: auth
    views: views

module.exports = init