should = require "should"
sinon = require "sinon"
twitter = require "../scripts/coffee/twitter"

describe "Twitter", ->
  global.XMLHttpRequest = () ->

  beforeEach (done) ->
    global.XMLHttpRequest.prototype =
      abort: () ->
      readyState: 4
      open: () ->
      onreadystatechange: null
      responseText: null
      send: () -> @onreadystatechange()
    done()

  afterEach (done) ->
    twitter.reset()
    done()


  testPattern = (tweet, query, track, artist, done) ->
    global.XMLHttpRequest.prototype.responseText = JSON.stringify 
      results: [ text: tweet, id: Math.round(Math.random()*10000) ]

    twitter.search query, (title, band, username, avatar_uri, fullname, profile_uri) -> 
      title.should.eql track if track
      band.should.eql artist if artist 
      should.not.exist title if !track
      should.not.exist band if !artist
      done()

  it "should parse the song title from a tweet as colon", (done) ->
    testPattern "play:where-the-wild #twimote", "twimote", "where-the-wild", null, () ->
      testPattern "i want to hear:where-the-wild #twimote", "twimote", "where-the-wild", null, () ->
        testPattern "#twimote listen:where-the-wild", "twimote", "where-the-wild", null, () ->
          testPattern "#twimote queue:johnson,_123", "twimote", "johnson,_123", null, () ->
            done()

  it "should parse the song title from a tweet as a dbl quoted string", (done) ->
    testPattern "play \"where the wild\" at #twimote", "twimote", "\"where the wild\"", null, () ->
      testPattern "i'd like to hear \"good, earth\" at #twimote today", "twimote", "\"good, earth\"", null, () ->
        testPattern "twimote pls queue \"bottle!  12!\" ok? \"yes!\"", "twimote", "\"bottle!  12!\"", null, () ->
          done()

  it "should parse the artist name from a tweet as colon", (done) ->
    testPattern "will you queue:something-else by:bjorn at #twimote", "twimote", "something-else", "bjorn", () ->
      testPattern "artist:take-that queue:something-else at #twimote", "twimote", "something-else", "take-that", () ->
        testPattern "play \"something else\" at #twimote band:brian-jonestown", "twimote", "\"something else\"", "brian-jonestown", () ->
          done()

  it "should parse the artist name from a tweet as a dbl quoted string", (done) ->
    testPattern "i want to hear \"we're the monkeys\", by \"The Monkeys\" at twimote", "twimote", "\"we're the monkeys\"", "\"The Monkeys\"", () ->
      testPattern "band \"green day\" play \"time of your life\" at twimote", "twimote", "\"time of your life\"", "\"green day\"", () ->
        testPattern "listen \"time of your life\" at twimote, artist \"Green day!\"", "twimote", "\"time of your life\"", "\"Green day!\"", () ->        
          done()

  it "should handle any order of play and by", (done) ->
    global.XMLHttpRequest.prototype.responseText = JSON.stringify 
      results: [ text:  "lorem ipsum idosyncraties #twimote by:nirvana-123 play:gone-wind-1" ]

    twitter.search "twimote", (title, band, request) -> 
      title.should.eql "gone-wind-1"
      band.should.eql "nirvana-123"
      done()

  it "should return full tweet details", (done) ->
    global.XMLHttpRequest.prototype.responseText = JSON.stringify 
      results:
        [ 
          text: "play:where-the-wild #twimote", from_user: "user1", 
          profile_image_url: "image", from_user_name: "name!"
        ]

    twitter.search "twimote", (title, band, request) -> 
      request.username.should.eql "user1"
      request.avatar_uri.should.eql "image"
      request.fullname.should.eql "name!"
      request.profile_uri.should.eql "http://twitter.com/#{request.username}"
      done()

  it "should emit searches for all found tweets", (done) ->
    global.XMLHttpRequest.prototype.responseText = JSON.stringify 
      results:
        [ 
          text: "play:song1 by:band1 twimote", id: 1
        ,
          text: "play:song2 by:band2 twimote", id: 2
        ,
          text: "play:song3 by:band3 twimote", id: 3 
        ]

    callback = sinon.spy()
    twitter.search "twimote", callback    
    sinon.assert.calledThrice(callback)
    sinon.assert.calledWith(callback, "song1", "band1")
    sinon.assert.calledWith(callback, "song2", "band2")
    sinon.assert.calledWith(callback, "song3", "band3")
    done()

  it "should cache tweets within subsequent query", (done) ->
    global.XMLHttpRequest.prototype.responseText = JSON.stringify 
      results:
        [ 
          text: "play:song1 by:band1 twimote", id: 1
        ,
          text: "play:song2 by:band2 twimote", id: 2
        ]

    twitter.search "twimote", () -> 
    global.XMLHttpRequest.prototype.responseText = JSON.stringify 
      results:
        [ 
          text: "play:song1 by:band1 twimote", id: 1
        ,
          text: "play:song2 by:band2 twimote", id: 2
        ,
          text: "play:song3 by:band3 twimote", id: 3 
        ]

    callback = sinon.spy()
    twitter.search "twimote", callback    
    sinon.assert.calledOnce(callback)
    sinon.assert.calledWith(callback, "song3", "band3")
    done()

  it "should not used cached tweets between different queries", (done) ->
    global.XMLHttpRequest.prototype.responseText = JSON.stringify 
      results:
        [ 
          text: "play:song1 by:band1 twimote", id: 1
        ,
          text: "play:song2 by:band2 twimote", id: 2
        ]

    twitter.search "otherquery", () -> 
    global.XMLHttpRequest.prototype.responseText = JSON.stringify 
      results:
        [ 
          text: "play:song1 by:band1 twimote", id: 1
        ,
          text: "play:song2 by:band2 twimote", id: 2
        ,
          text: "play:song3 by:band3 twimote", id: 3 
        ]

    callback = sinon.spy()
    twitter.search "twimote", callback    
    sinon.assert.calledThrice(callback)
    sinon.assert.calledWith(callback, "song1", "band1")
    sinon.assert.calledWith(callback, "song2", "band2")
    sinon.assert.calledWith(callback, "song3", "band3")
    done()