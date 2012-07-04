xhr = undefined
tweetsByQuery = {}

search = (query, next) ->
  xhr.abort() if xhr
  xhr = new XMLHttpRequest()
  xhr.open "GET", "http://search.twitter.com/search.json?q=" + query
  xhr.onreadystatechange = ->
    return unless xhr.readyState is 4
    data = JSON.parse(xhr.responseText)
    data.results.forEach (result) ->
      return if cached query, result
      tweet = result.text
      track = tweet.match(/(?=play:).+?(?=\s|$)/i)?[0].substr(5)
      artist = tweet.match(/(?=by:).+?(?=\s|$)/i)?[0].substr(3)
      next track, artist, result.from_user, result.profile_image_url, result.from_user_name
      , "http://twitter.com/#{result.from_user}" if (track)
    xhr.onreadystatechange = null 
  xhr.send()  

cached = (query, tweet) -> 
  tweetsByQuery[query]?= {}
  status = tweetsByQuery[query][tweet.id]?
  tweetsByQuery[query][tweet.id]?= tweet
  status

exports.search = search