image = (uri, klass) ->
  img = undefined
  img = new Image()
  img.className = klass ? "thumb"
  img.src = uri
  img.outerHTML

exports.image = image