track = undefined
notFound = undefined
error = undefined

search = 
  spotify: (title, artist, random, done) -> done track, notFound, error #found result

{should, sinon, auth} = require("./base")
  "/scripts/js/search": search

queuer = require "../scripts/coffee/queuer"

describe "Queuer", ->

  timeout = undefined
  match = undefined
  request = undefined 
  clock = undefined

  beforeEach (done) ->
    track = {}
    notFound = false
    error = null

    clock = sinon.useFakeTimers()

    match = 
      track: 'track'
      artist: 'artist'
      random: false

    request = {}

    done()

  afterEach (done) -> 
    clock.restore() 
    queuer.reset()
    done()

  it "must run when turned on", (done) ->
    spy = sinon.spy()
    queuer.add match, request, spy

    queuer.turn on, 10
    clock.tick(50)
    queuer.turn off

    sinon.assert.calledOnce(spy)
    sinon.assert.calledWith spy, track
    done() 

  it "must start in off state", (done) ->
    spy1 = sinon.spy()
    spy2 = sinon.spy()
    queuer.add match, request, spy1
    clock.tick(500)
    queuer.add match, request, spy2
    clock.tick(100000)

    sinon.assert.notCalled(spy1)
    sinon.assert.notCalled(spy2)
    done()

  it "must stop running when turned off", (done) ->
    spy = sinon.spy()
    queuer.turn on, 10
    queuer.add match, request, () ->
    
    clock.tick(1000)
    queuer.turn off
    queuer.add match, request, spy
    clock.tick(10000)

    sinon.assert.notCalled(spy)
    done()

  it "must clear all items when reset is called", (done) ->
    spy = sinon.spy()
    queuer.add match, request, spy 
    queuer.reset()
    clock.tick(100000)
    sinon.assert.notCalled(spy)
    done()

  it "should resume when turned back on", (done) ->
    spy1 = sinon.spy()
    spy2 = sinon.spy()
    
    queuer.add match, request, spy1
    queuer.add match, request, spy2
      
    queuer.turn on, 10
    clock.tick 11

    queuer.turn off
    sinon.assert.calledOnce spy1
    sinon.assert.notCalled spy2
  
    queuer.turn on
    clock.tick 11

    sinon.assert.calledOnce spy2

    done()


  it "should pass through notFound status", (done) ->
    notFound = true
    track = null

    spy = sinon.spy()

    queuer.turn on, 10
    queuer.add match, request, spy

    clock.tick 11
    queuer.turn off

    sinon.assert.calledWith spy, null, true

    done()

  it "should recall indefinitely if errors in search", (done) ->
    callcount = 0

    search.spotify = (t, a, r, done) -> 
      callcount++
      done null, false, "some error"

    spy = sinon.spy()

    queuer.turn on, 100
    queuer.add match, request, spy

    for i in [1..10]
      clock.tick 101
      sinon.assert.notCalled spy
      callcount.should.eql i

    search.spotify = (t, a, r, done) -> done track
    clock.tick 101
    sinon.assert.calledOnce spy
    sinon.assert.calledWith spy, track
    done()