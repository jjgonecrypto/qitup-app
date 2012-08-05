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
  #exeCount = undefined
  clock = undefined

  beforeEach (done) ->
    track = {}
    notFound = false
    error = null

    clock = sinon.useFakeTimers()

    ###
    exeCount = 0
    maxExecutions = 5

    timeout = global.setTimeout
    global.setTimeout = (fnc, ms) -> 
      if exeCount < maxExecutions
        exeCount++
        return fnc()
      timeout fnc, ms
    global.clearTimeout = (id) -> 
      global.setTimeout = timeout
    ###
    match = 
      track: 'track'
      artist: 'artist'
      random: false
    request = {}

    done()

  afterEach (done) -> 
    clock.restore() 
    done()

  it "must run when turned on", (done) ->
    spy = sinon.spy()
    queuer.add match, request, spy

    queuer.turn on
    clock.tick(100000)
    queuer.turn off

    sinon.assert.calledOnce(spy)
    sinon.assert.calledWith spy, track
    done() 

  it "should stop running when turned off", (done) ->
    #spy = sinon.spy()
    #queuer.add match, request, spy

    #queuer.turn on
    #queuer.turn off
    done()

  it "must clear all items when reset is called"  


  it "should resume when turned back on"

  it "should recall indefinitely if errors in search"

  it "should pass through notFound status"