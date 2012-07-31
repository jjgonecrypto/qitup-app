swah = (selector) ->
  result = document.querySelectorAll selector	

  forEach = (callback) ->
    callback result[i] for i in [0..result.length]

  return hash =
    html: (value) ->
      if value
        forEach (item) -> item?.innerHTML = value
      else
        html = ""
        forEach (item) -> html += item?.innerHTML
        html  
    raw: result
    length: result.length


exports.swah = swah