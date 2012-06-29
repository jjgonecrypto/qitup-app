image = (uri, width, height) ->
  img = undefined
  width = width or 50
  height = height or 50
  img = new Image(width, height)
  img.src = uri
  img.outerHTML

exports.image = image