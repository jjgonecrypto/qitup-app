should = require "should"
twitter = require "../scripts/coffee/twitter"

describe "Twitter", ->

  global.XMLHttpRequest = () ->
  global.XMLHttpRequest.prototype =
    abort: () ->
    readyState: 4
    open: () ->
    send: () -> setTimeout @onreadystatechange, 1

  afterEach (done) ->
    global.XMLHttpRequest.prototype.onreadystatechange = null
    done()

  it "should parse the song title from a tweet", (done) ->
    global.XMLHttpRequest.prototype.responseText = '{"results": [{
        "text": "play:where-the-wild #twimote"}
      ]}'

    twitter.search "twimote", (title, band, username, avatar_uri, fullname, profile_uri) -> 
      title.should.eql "where-the-wild"
      should.not.exist band
      done()

  it "should handle any order of play and by", (done) ->
    global.XMLHttpRequest.prototype.responseText = '{"results": [{
        "text": "lorem ipsum idosyncraties #twimote by:nirvana-123 play:where-the-wild"}
      ]}'

    twitter.search "twimote", (title, band, username, avatar_uri, fullname, profile_uri) -> 
      title.should.eql "where-the-wild"
      band.should.eql "nirvana-123"
      done()

  it "should return full tweet details", (done) ->
    global.XMLHttpRequest.prototype.responseText = '{"results": [{
        "text": "play:where-the-wild #twimote",
        "from_user": "user1",
        "profile_image_url": "image",
        "from_user_name": "name!"}
      ]}'
    twitter.search "twimote", (title, band, username, avatar_uri, fullname, profile_uri) -> 
      username.should.eql "user1"
      avatar_uri.should.eql "image"
      fullname.should.eql "name!"
      profile_uri.should.eql "http://twitter.com/#{username}"
      done()