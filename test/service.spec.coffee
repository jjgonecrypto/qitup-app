{should, sinon, auth} = require("./base")()

Service = require("../scripts/coffee/service").Service

describe "Service", ->
  service = undefined

  beforeEach (done) ->
    service = new Service()
    done()

  afterEach (done) ->
    service = undefined
    done()

  assertCallsImplementation = (service, base, implementation, done) ->
    (() -> service[base] () ->).should.throw()

    spy = sinon.spy()
    service[implementation] = spy

    service[base] () ->
    sinon.assert.calledOnce(spy)
    done()

  it "must set search criteria", (done) ->
    criteria = 
      keywords: ['first']
      users: ['someone', 'else']
      future: true
    
    service.setCriteria criteria 
    service.getCriteria().should.eql criteria
    done()

  it "must call the service's auth implementation", (done) ->
    assertCallsImplementation service, "authenticate", "doAuthenticate", () -> done()

  it "must callback after auth implementation is done", (done) ->
    res = {}
    err = null
    service.doAuthenticate = (callback) ->
      callback res, err

    service.authenticate (result, error) ->
      result.should.eql res
      should.not.exist error
      err = "i am error"
      service.authenticate (result, error) ->
        should.not.exist(result)
        error.should.eql err
        done()

  it "must have authenticated status once authenticated", (done) ->
    service.doAuthenticate = (callback) -> callback {}

    service.authenticate () ->
      service.authenticated.should.eql true
      done()

  it "must set onDeauth callback via authentication", (done) ->
    service.doAuthenticate = (callback) -> callback {}
    onDeauth = () ->

    service.authenticate () ->
      service.onDeauth.should.eql onDeauth
      done()
    , onDeauth

  it "must call doLogout implementation", (done) ->
    service.authenticated = true
    assertCallsImplementation service, "logout", "doLogout", () -> done()

  it "must call doLogout callback only when authenticated", (done) ->
    spy = sinon.spy()
    service.doLogout = spy
    service.authenticated = false
    service.logout(() ->)
    sinon.assert.notCalled spy
    done()
  
  it "must callback after logout implementation is done", (done) ->
    service.authenticated = true
    err = null
    service.doLogout = (callback) -> callback err

    service.logout (error) ->
      should.not.exist error
      service.authenticated = true
      err = "i am error"
      service.logout (error) ->
        error.should.eql err
        done()

  it "must not have authenticated status once logout", (done) ->
    service.authenticated = true
    err = null
    service.doLogout = (callback) -> callback err

    service.logout (error) ->
      service.authenticated.should.eql false
      service.authenticated = true
      err = "i am error"
      service.logout (error) ->
        service.authenticated.should.eql true
        done()

  it "must call search callback", (done) ->
    (() -> service.search () ->).should.throw()
    service.setCriteria {}
    assertCallsImplementation service, "search", "doSearch", () -> done()

  it "must pass through responses back from implementation", (done) ->
    res = 
      id: 123
    service.doSearch = (callback) -> callback res
    service.setCriteria {}    
    service.search (result, ser) ->
      result.should.eql res
      ser.should.eql service
      done()

  it "must pass cache responses and not repeat them", (done) ->
    res = 
      id: 123
    service.doSearch = (callback) -> callback res
    service.setCriteria {}
    spy = sinon.spy()    
    service.search spy
    sinon.assert.calledOnce spy

    spy2 = sinon.spy()
    service.search spy2
    sinon.assert.notCalled spy2    
    done()

  it "must ignore past entries when instructed", (done) ->
    res = 
      id: 1
      created: new Date(new Date().getTime() - 1000)
    service.doSearch = (callback) -> callback res
    service.setCriteria 
      future: true
    spy = sinon.spy()    
    service.search spy
    sinon.assert.notCalled spy

    res = 
      id: 2
      created: new Date(new Date().getTime() + 1000)
    spy2 = sinon.spy()
    service.search spy2
    sinon.assert.calledOnce spy2

    done()

  it "must call message implementation", (done) ->
    service.authenticated = true
    assertCallsImplementation service, "message", "doMessage", () -> done()

  it "must pass through messages from implementation", (done) ->
    p = {}
    t = ""
    res = {id:123}
    err = undefined
    service.authenticated = true
    service.doMessage = (post, text, callback) ->
      post.should.eql p
      text.should.eql t
      callback res, err

    service.message p, t, (error) ->
      should.not.exist error
      err = "some error"
      service.message p, t, (error) ->
        error.should.eql err  
        done()

  it "must ignore search results with same id as sent message", (done) ->
    res = 
      id: 1
      created: new Date(new Date().getTime() - 1000)
    service.authenticated = true
    service.doMessage = (post, text, callback) -> callback res
    service.message {}, "", (error) ->
    service.doSearch = (callback) -> callback res
    service.setCriteria {}
    spy = sinon.spy()    
    service.search spy
    sinon.assert.notCalled spy
    done()

