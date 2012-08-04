{should, sinon, auth} = require("./base")()

matcher = require "../scripts/coffee/matcher"

describe "Matcher", ->

  testPattern = (stripped, track, artist, random, done) ->
    matcher.match stripped, (match) -> 
      if !track and !artist 
        should.not.exist match
      else  
        match.track.should.eql track if track
        match.artist.should.eql artist if artist 
        should.not.exist match.track if !track
        should.not.exist match.artist if !artist
        match.random.should.eql random
      done()

  it "should parse the song title from request as colon", (done) ->
    testPattern "play:where-the-wild", "where-the-wild", null, false, () ->
      testPattern "i want to hear:where-the-wild", "where-the-wild", null, false, () ->
        testPattern "can we listen:where-the-wild ok??", "where-the-wild", null, false, () ->
          testPattern "just queue:johnson,_123 now!", "johnson,_123", null, false, () ->
            done()

  it "should parse the song title from request as a dbl quoted string", (done) ->
    testPattern "play \"where the wild\" at #sometag", "\"where the wild\"", null, false, () ->
      testPattern "@jeff i'd like to hear \"good, earth\" at event today //cc @paul", "\"good, earth\"", null, false, () ->
        testPattern "twimote pls queue \"bottle!  12!\" ok? \"yes!\"", "\"bottle!  12!\"", null, false, () ->
          done()

  it "should parse the artist name from request as colon", (done) ->
    testPattern "will you queue:someone-else by:bjorn at #event", "someone-else", "bjorn", false, () ->
      testPattern "@john @paul artist:take-that queue:someone-else at twimote", "someone-else", "take-that", false, () ->
        testPattern "play \"someone else\" at #event band:brian-jonestown", "\"someone else\"", "brian-jonestown", false, () ->
          done()

  it "should parse the artist name from request as a dbl quoted string", (done) ->
    testPattern "i want to hear \"we're the monkeys\", by \"The Monkeys\" at twimote", "\"we're the monkeys\"", "\"The Monkeys\"", false, () ->
      testPattern "listen \"time of your life\" at twimote, artist \"Green day!\"", "\"time of your life\"", "\"Green day!\"", false, () ->        
        done()

  it "should handle artist name first then band", (done) ->
    testPattern "by \"The Monkeys\" hear \"we're the monkeys\" at twimote", "\"we're the monkeys\"", "\"The Monkeys\"", false, () ->
      testPattern "band \"green day\" play \"time of your life\" at twimote", "\"time of your life\"", "\"green day\"", false, () ->
        done()

  it "should parse lh and rh double quote strings", (done) ->
    testPattern "play “hoochie mama” by “2 live crew” #event", "“hoochie mama”", "“2 live crew”", false, () ->
      testPattern "play “hoochie mama” by \"2 live crew\" #event ok???", "“hoochie mama”", "\"2 live crew\"", false, () ->
        done()

  it "should ignore whitespace between identifier and double quotes", (done) ->
    testPattern "play     \"artist\"   by    \"xxyyxx\" #event", "\"artist\"", "\"xxyyxx\"", false, () ->
      done()

  it "should handle multiple play/band keywords", (done) ->
    testPattern "by some band play \"artist\" by by \"xxyyxx\" play ok?", "\"artist\"", "\"xxyyxx\"", false, () ->
      done()

  it "should handle empty track titles", (done) ->
    testPattern "queue track by \"the clash\" #twimote", null, "\"the clash\"", false, () ->
      done()

  it "should handle requests for random tracks", (done) ->
    testPattern "i want to hear something by \"the clash\" #twimote", null, "\"the clash\"", true, () ->
      testPattern "play anything by \"the clash\" #twimote", null, "\"the clash\"", true, () ->
        testPattern "by \"the anything clash\" #ev-twimote", null, "\"the anything clash\"", false, () ->
          testPattern "play \"something else\" #twimote", "\"something else\"", null, false, () ->
            testPattern "play * by \"the smiths\" #twimote", null, "\"the smiths\"", true, () ->
              done()
