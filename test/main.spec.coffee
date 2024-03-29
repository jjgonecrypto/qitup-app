{should, sinon, auth} = require("./base")()

main = require "../scripts/coffee/main"

describe "Main", ->

  it "should search all known attached services on search"

  it "should poll services continually"

  it "should reply with message if track not found"

  it "should handle already played state"

  it "must not queue a song that has already been in the queue if allow dupes is off"

  it "should handle non-playable tracks"

  it "should add to existing playlist"

  it "should add and play to existing playlist if off"
