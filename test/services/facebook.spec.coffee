{should, sinon, auth} = require("./base")()

Facebook = require "../scripts/coffee/services/facebook"

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

  it "must authenticate"

  it "must try reauthenticate on 400 expiry"

  it "must call authenticate error callback on all other non HTTP 200 search responses"

  # it "must be authed to do requests???"


###
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

  requestStub = (text, stripped) ->
    base = 
      username: undefined
      fullname: undefined
      avatar_uri: undefined
      profile_uri: "http://twitter.com/undefined"
      id: undefined
      text: text
      stripped: if stripped then stripped else text
###