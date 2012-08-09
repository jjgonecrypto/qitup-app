image = (uri, klass) ->
  img = undefined
  img = new Image()
  img.className = klass ? "thumb"
  img.src = uri
  img.outerHTML

parseUri = (uri, key) ->
  uri.match(new RegExp("#{key}=.+?(?=$|&)"))?[0].substr("#{key}=".length) ? console.log("no match for #{key}!")

exports.image = image
exports.parseUri = parseUri