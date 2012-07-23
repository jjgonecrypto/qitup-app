should = require "should"
sinon = require "sinon"

auth = {}
global.getSpotifyApi = () -> 
  require: (module) -> 
    return require "../#{module}" unless (module.indexOf "sp://") is 0
    if module is "sp://import/scripts/api/auth" then auth else {}
global.XMLHttpRequest = () ->

twitter = require "../scripts/coffee/twitter"

describe "Twitter", ->

  beforeEach (done) ->
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
    twitter.reset()
    done()

  setResponse = (results) ->
    global.XMLHttpRequest.prototype.responseText = JSON.stringify 
      results: results

  testPattern = (tweet, query, track, artist, done) ->
    setResponse [ text: tweet, id: Math.round(Math.random()*10000) ]

    twitter.search {query: query}, (title, band, username, avatar_uri, fullname, profile_uri) -> 
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

  it "should parse lh and rh double quote strings", (done) ->
    testPattern "play “hoochie mama” by “2 live crew” #twimote", "twimote", "“hoochie mama”", "“2 live crew”", () ->
      testPattern "play “hoochie mama” by \"2 live crew\" #twimote", "twimote", "“hoochie mama”", "\"2 live crew\"", () ->
        done()

  it "should ignore whitespace between identifier and double quotes", (done) ->
    testPattern "play     \"artist\"   by    \"xxyyxx\" #twimote", "twimote", "\"artist\"", "\"xxyyxx\"", () ->
      done()

  it "should handle empty track titles", (done) ->
    testPattern "queue something by \"the clash\" #twimote", "twimote", null, "\"the clash\"", () ->
      done()

  it "should handle any order of play and by", (done) ->
    global.XMLHttpRequest.prototype.responseText = JSON.stringify 
      results: [ text:  "lorem ipsum idosyncraties #twimote by:nirvana-123 play:gone-wind-1" ]

    twitter.search {query: "twimote"}, (title, band, request) -> 
      title.should.eql "gone-wind-1"
      band.should.eql "nirvana-123"
      done()

  it "should return full tweet details", (done) ->
    setResponse [ 
      text: "play:where-the-wild #twimote"
      from_user: "user1", 
      profile_image_url: "image"
      from_user_name: "name!"
    ]

    twitter.search {query: "twimote"}, (title, band, request) -> 
      request.username.should.eql "user1"
      request.avatar_uri.should.eql "image"
      request.fullname.should.eql "name!"
      request.profile_uri.should.eql "http://twitter.com/#{request.username}"
      done()

  it "should emit searches for all found tweets", (done) ->
    setResponse [ 
      text: "play:song1 by:band1 twimote", id: 1
    ,
      text: "play:song2 by:band2 twimote", id: 2
    ,
      text: "play:song3 by:band3 twimote", id: 3 
    ]

    callback = sinon.spy()
    twitter.search {query: "twimote"}, callback    
    sinon.assert.calledThrice(callback)
    sinon.assert.calledWith(callback, "song1", "band1")
    sinon.assert.calledWith(callback, "song2", "band2")
    sinon.assert.calledWith(callback, "song3", "band3")
    done()

  it "should cache tweets within subsequent query", (done) ->
    setResponse [ 
      text: "play:song1 by:band1 twimote", id: 1
    ,
      text: "play:song2 by:band2 twimote", id: 2
    ]

    twitter.search {query: "twimote"}, () -> 
    setResponse [ 
      text: "play:song1 by:band1 twimote", id: 1
    ,
      text: "play:song2 by:band2 twimote", id: 2
    ,
      text: "play:song3 by:band3 twimote", id: 3 
    ]

    callback = sinon.spy()
    twitter.search {query: "twimote"}, callback    
    sinon.assert.calledOnce(callback)
    sinon.assert.calledWith(callback, "song3", "band3")
    done()

  it "should not used cached tweets between different queries", (done) ->
    setResponse [ 
      text: "play:song1 by:band1 twimote", id: 1
    ,
      text: "play:song2 by:band2 twimote", id: 2
    ]

    twitter.search {query: "otherquery"}, () -> 
    setResponse [ 
      text: "play:song1 by:band1 twimote", id: 1
    ,
      text: "play:song2 by:band2 twimote", id: 2
    ,
      text: "play:song3 by:band3 twimote", id: 3 
    ]

    callback = sinon.spy()
    twitter.search {query: "twimote"}, callback    
    sinon.assert.calledThrice(callback)
    sinon.assert.calledWith(callback, "song1", "band1")
    sinon.assert.calledWith(callback, "song2", "band2")
    sinon.assert.calledWith(callback, "song3", "band3")
    done()

  oauth_token = "A123"
  oauth_secret = "BX99"
  oauth_verifier = "53D1"
  access_token = "67D32"
  access_secret = "871EF"
  screen_name = "justin"
  user_id = "123"

  twitterSignIn = (callback, deny) ->

    global.XMLHttpRequest.prototype.responseText = "oauth_token=#{oauth_token}&oauth_secret=#{oauth_secret}&oauth_callback_confirmed=true"

    auth.showAuthenticationDialog = (uri, callback_uri, actions) ->
      uri.should.eql "https://api.twitter.com/oauth/authorize?oauth_token=#{oauth_token}"
      callback_uri.should.eql "http://qitup.fm"
      global.XMLHttpRequest.prototype.send = () ->
        @responseText = "?oauth_token=#{access_token}&oauth_token_secret=#{access_secret}&user_id=#{user_id}&screen_name=#{screen_name}"
        @onreadystatechange()
      if deny then actions.onSuccess "?denied=#{oauth_token}" else actions.onSuccess "?oauth_verifier=#{oauth_verifier}"

    twitter.authenticate (response, err) ->
      if deny
        err.should.not.eql null
        return callback()

      throw err if err
      twitter.logged_in().should.eql true
      response.screen_name.should.eql screen_name
      response.user_id.should.eql user_id
      
      callback()

  it "should perform 3-legged authentication with twitter", (done) ->
    twitterSignIn done 

  it "should perform throw error if auth is denied by user", (done) ->
    twitterSignIn done, true    

  it "should message users via twitter API with correct access token and secret", (done) ->
    tweet = 
      id: "12345"
      username: "justin"
    text = "thanks!"

    twitterSignIn () ->
      global.XMLHttpRequest.prototype.setRequestHeader = (name, header) -> 
        if name is "Authorization"
          header.indexOf("oauth_token=\"#{access_token}\"").should.be.above(0) 
      global.XMLHttpRequest.prototype.send = (data) -> 
        data.indexOf("in_reply_to_status_id=#{tweet.id}").should.be.above(-1)
        @onreadystatechange()

      twitter.message tweet, text, (err, data) ->
        throw err if err 
        done()