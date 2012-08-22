{should, sinon, auth} = require("./base")()

Service = require("../scripts/coffee/service").Service

describe "Service", ->
  service = undefined

  beforeEach (done) ->
    service = new Service()
    done()

  afterEach (done) ->
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
    (() -> service.authenticate()).should.throw()

    spy = sinon.spy()
    service.doAuthenticate = spy

    service.authenticate()
    sinon.assert.calledOnce(spy)
    done()

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

  it "must call doLogout callback only when authenticated", (done) ->
    service.authenticated = true
    (() -> service.logout () ->).should.throw()
    
    spy = sinon.spy()
    service.doLogout = spy
    service.authenticated = false
    service.logout(() ->)
    sinon.assert.notCalled spy

    service.authenticated = true
    service.logout(() ->)
    sinon.assert.calledOnce spy
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
    (() -> service.search()).should.throw()

    spy = sinon.spy()
    service.doSearch = spy

    service.search()
    sinon.assert.calledOnce(spy)
    done()


