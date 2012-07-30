image = (uri) ->
  img = undefined
  img = new Image()
  img.className = "thumb"
  img.src = uri
  img.outerHTML

exports.image = image