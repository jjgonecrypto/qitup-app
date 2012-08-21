{should, sinon, auth} = require("./base")()

Service = require("../scripts/coffee/service").Service

describe "Service", ->
  service = undefined

  beforeEach (done) ->
    service = new Service()
    done()

  afterEach (done) ->
    done()

  it "must pass through criteria to search", (done) ->
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

  it "must have authenticated status once authenticated"


  it "must set onDeauth callback via authentication"

  it "must call doLogout callback"

  it "must not have authenticated status once logout"

  it "must call search callback"

