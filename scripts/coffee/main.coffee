sp = getSpotifyApi 1

init = ->
  models = sp.require "sp://import/scripts/api/models"
  hashtag = document.getElementById "hashtag"
  searchBtn = document.getElementById "search"
  status = document.getElementById "details"
  searchBtn.addEventListener "click", ->
    status.innerHTML = ""
    playlist = new models.Playlist()
    xhr = new XMLHttpRequest()
    request = "http://search.twitter.com/search.json?q=" + hashtag.value
    xhr.open "GET", request
    xhr.onreadystatechange = ->
      return  unless xhr.readyState is 4
      data = JSON.parse(xhr.responseText)
      html = ""
      data.results.forEach (result) ->
        tweet = result.text
        trackName = tweet.match(/(?=play:).+?(?=\s)/i)[0].substr(5)
        if trackName.length
          search = new models.Search(trackName)
          search.observe models.EVENT.CHANGE, ->
            if search.tracks.length
              track = search.tracks[0]
              return  if playlist.indexOf(track) >= 0
              playlist.add track
              models.player.play track, playlist, 0  if playlist.length is 1
              html += "<li><ul class='inline'>"
              html += "<li>" + image(track.image) + "</li>"
              html += "<li class='track'><strong>" + track.name + "</strong><br />by " + track.artists[0].name + "</li>"
              html += "<li>" + image(result.profile_image_url) + "</li>"
              html += "<li class='user'><a href='http://twitter.com/" + result.from_user + "'>" + result.from_user_name + " (@" + result.from_user + ")" + "</a></li>"
              html += "</ul></li>"
            status.innerHTML = "<ul class='results'>" + html + "</ul>"
            search.ignore models.EVENT.CHANGE

          search.appendNext()

      xhr.onreadystatechange = null

    xhr.send null
image = (uri, width, height) ->
  img = undefined
  width = width or 50
  height = height or 50
  img = new Image(width, height)
  img.src = uri
  img.outerHTML

exports.init = init