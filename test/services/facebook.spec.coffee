keys = 
  facebook: 
    appID: 12345
ajaxDone = undefined
ajaxFail = undefined
swah =
  swah: 
    ajax: (opts) -> result = 
      done: (callback) -> ajaxDone() if ajaxDone instanceof Function
      fail: (callback) -> ajaxFail() if ajaxFail instanceof Function

{should, sinon, auth} = require("../base")
  "/scripts/js/service-keys": keys
  "/scripts/js/swah": swah

Facebook = require("../../scripts/coffee/services/facebook").Facebook

describe "Facebook", ->

  facebook = undefined

  beforeEach (done) ->
    facebook = new Facebook()
    
    global.XMLHttpRequest.prototype =
      abort: () ->
      readyState: 4
      open: () ->
      status: 200
      onreadystatechange: null
      responseText: null
      send: () -> @onreadystatechange()
      setRequestHeader: () ->

    done()

  afterEach (done) ->
    facebook = undefined
    done()

  it "must call spotify authenticateWithFacebook method", (done) -> 
    spy = sinon.spy() 
    auth.authenticateWithFacebook = spy
    facebook.authenticate()
    sinon.assert.calledWith spy, keys.facebook.appID, facebook.permissions
    done()

  it "must handle spotify auth success return", (done) ->
    accessToken = 333
    ttl = 5500
    auth.authenticateWithFacebook = (appID, perm, callbacks) ->
      callbacks.onSuccess accessToken, ttl
    facebook.authenticate (result, err) ->
      result.should.eql accessToken
      facebook.authenticated.should.eql true
      facebook.accessToken.should.eql accessToken
      done()  

  it "must handle spotify auth error return", (done) ->
    error = "i am error"
    auth.authenticateWithFacebook = (appID, perm, callbacks) ->
      callbacks.onFailure error
    facebook.authenticate (result, err) ->
      should.not.exist result
      err.should.eql error
      facebook.authenticated.should.eql false
      done()  

  it "must process logout when instructed", (done) ->
    done()

  it "must try reauthenticate on search receiving 400 expiry"

  it "must call authenticate error callback on all other non HTTP 200 search responses"

  # it "must be authed to do requests???"

