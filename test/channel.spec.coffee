{should, sinon, auth} = require("./base")()

Channel = require("../scripts/coffee/service").Service

describe "Channel", ->
  channel = undefined

  beforeEach (done) ->
    channel = new Channel()

  afterEach (done) ->
    channel = undefined

  it "must add on services"

  it "must start polling"

  it "must stop polling"

  it "must search all contained services"

  it "must create and add to any existing playlist"