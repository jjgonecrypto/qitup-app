keys = 
  facebook: 
    appID: 12345
ajaxResult = undefined
ajaxError = undefined
abort = undefined
swah =
  swah: 
    ajax: (opts) -> result = 
      done: (callback) -> 
        callback ajaxResult if !ajaxError
        @
      fail: (callback) -> 
        callback ajaxError if ajaxError
        @
      abort: () -> 
        console.log "aborting!"
        abort() if abort instanceof Function
      

{should, sinon, auth} = require("../base")
  "/scripts/js/service-keys": keys
  "/scripts/js/swah": swah

Facebook = require("../../scripts/coffee/services/facebook").Facebook

describe "Facebook", ->

  facebook = undefined

  beforeEach (done) ->
    facebook = new Facebook()

    ajaxResult = undefined
    ajaxError = undefined
    callAbort = undefined

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
    sinon.assert.calledWith spy, keys.facebook.appID
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
    facebook.authenticated = true
    ajaxResult = {}
    facebook.logout (err) ->
      facebook.authenticated.should.eql false
      facebook.authenticated = true
    abort = sinon.spy()
    facebook.logout (err) ->
      sinon.assert.calledOnce abort
      done()
  
  it "must not logout if error encountered", (done) ->
    facebook.authenticated = true
    ajaxError = "i am error"
    facebook.logout (err) ->
      err.should.eql ajaxError
      facebook.authenticated.should.eql true
      done()
  
  it "must try reauthenticate on search receiving 400 expiry"
    #todo

  it "must call authenticate error callback on all other non HTTP 200 search responses"
    #todo

  it "must generate endpoints for criteria", (done) ->
    first = "keyword1"
    second = "keyword2"
    user1 = "user1"
    user2 = "user2"

    facebook.setCriteria
      keywords: [first, second]
      usernames: [user1, user2]

    facebook.authenticated = true
    oldAjax = swah.swah.ajax
    spy = sinon.spy swah.swah.ajax
    swah.swah.ajax = spy
    ajaxResult = 
      paging:
        previous: "123"
      data: []  
    
    facebook.search()
    sinon.assert.calledThrice spy
    sinon.assert.calledWith spy, 
      uri: "https://graph.facebook.com/search?q=keyword1+OR+keyword2&"
    sinon.assert.calledWith spy, 
      uri: "https://graph.facebook.com/user1/feed?"
    sinon.assert.calledWith spy, 
      uri: "https://graph.facebook.com/user2/feed?"
    
    swah.swah.ajax = oldAjax
    done()

  it "must abort old requests per endpoint when new comes through"
  # it "must be authed to do requests???"

