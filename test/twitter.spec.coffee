{should, sinon, auth} = require("./base")()

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

   it "should return full tweet details", (done) ->
    setResponse [ 
      text: "play:where-the-wild #twimote"
      from_user: "user1", 
      profile_image_url: "image"
      from_user_name: "name!"
    ]

    twitter.search {query: "twimote"}, (request) -> 
      request.username.should.eql "user1"
      request.avatar_uri.should.eql "image"
      request.fullname.should.eql "name!"
      request.profile_uri.should.eql "http://twitter.com/#{request.username}"
      done()

  requestStub = (text, query) ->
    base = 
      username: undefined
      fullname: undefined
      avatar_uri: undefined
      profile_uri: "http://twitter.com/undefined"
      id: undefined

    base.text = text
    base.stripped = text.replace(query, "")
    base

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
    
    sinon.assert.calledWith(callback, requestStub("play:song1 by:band1 twimote", "twimote"))
    sinon.assert.calledWith(callback, requestStub("play:song2 by:band2 twimote", "twimote"))
    sinon.assert.calledWith(callback, requestStub("play:song3 by:band3 twimote", "twimote"))
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
    sinon.assert.calledWith(callback, requestStub("play:song3 by:band3 twimote", "twimote"))
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
    sinon.assert.calledWith(callback, requestStub("play:song1 by:band1 twimote", "twimote"))
    sinon.assert.calledWith(callback, requestStub("play:song2 by:band2 twimote", "twimote"))
    sinon.assert.calledWith(callback, requestStub("play:song3 by:band3 twimote", "twimote"))
    done()


  it "should strip keywords from the tweet"


  it "should not return past tweets if from_now is true", (done) ->
    setResponse [ 
      text: "play:song1 by:band1 twimote", id: 1, created_at: new Date(new Date().getTime() - 1000)
    ,
      text: "play:song2 by:band2 twimote", id: 2, created_at: new Date(new Date().getTime() + 1500)
    ,
      text: "play:song3 by:band3 twimote", id: 3, created_at: new Date(new Date().getTime() + 6000)
    ]

    callback = sinon.spy()
    twitter.search 
      query: "twimote"
      from_date: new Date()
    , callback    
    sinon.assert.calledTwice(callback)
    sinon.assert.calledWith(callback, requestStub("play:song2 by:band2 twimote", "twimote"))
    sinon.assert.calledWith(callback, requestStub("play:song3 by:band3 twimote", "twimote"))
    
    #reset these to create new IDs, preventing cache from coming into effect
    setResponse [ 
      text: "play:song1 by:band1 twimote", id: 21, created_at: new Date(new Date().getTime() - 1000)
    ,
      text: "play:song2 by:band2 twimote", id: 22, created_at: new Date(new Date().getTime())
    ,
      text: "play:song3 by:band3 twimote", id: 23, created_at: new Date(new Date().getTime() + 6000)
    ]

    callback2 = sinon.spy()
    twitter.search 
      query: "twimote"
      from_date: new Date(new Date().getTime() + 3000)
    , callback2   
    sinon.assert.calledOnce(callback2)
    sinon.assert.calledWith(callback2, requestStub("play:song3 by:band3 twimote", "twimote"))
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