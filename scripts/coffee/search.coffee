spotify = (title, artist) ->
  search = new models.Search title
  search.observe models.EVENT.CHANGE, () ->
    search.ignore models.EVENT.CHANGE #remove listener
    return search.tracks[0] if search.tracks.length
  search.appendNext()

exports.spotify = spotify