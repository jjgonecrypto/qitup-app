swah = (selector) ->
  result = if selector instanceof Node then [selector] else document.querySelectorAll selector	

  forEach = (callback) ->
    callback result[i] for i in [0..result.length]

  return hash =
    html: (value) ->
      if typeof(value) is "string"
        forEach (item) -> item?.innerHTML = value
      else
        html = ""
        forEach (item) -> html += item?.innerHTML
        html  
    append: (html) ->
      last = undefined
      forEach (item) -> 
        item?.innerHTML += html
        last = if item?.lastChild? then item.lastChild else last 
      swah(last) if last
    raw: if result instanceof Array then result[0] else result
    length: result.length
    on: (evt, callback) ->
      forEach (item) -> item?.addEventListener evt, (e) -> callback(e)
    addClass: (clazz) ->
      forEach (item) -> 
        return unless item and item.className?.toLowerCase().indexOf(clazz.toLowerCase()) is -1
        item?.className += " #{clazz}"
    removeClass: (clazz) ->
      forEach (item) -> 
        item.className = item?.className?.replace(new RegExp(clazz, "gi"), "") if item
    className: (clazz) ->
      forEach (item) -> item?.className = clazz 
    checked: (to) ->
      throw "not implemented" if to
      status = false 
      forEach (item) -> status = status or item?.checked
      status
    val: (value) ->
      found = ""
      forEach (item) -> 
        if typeof(value) is "string"
          found = item.value = value if item
        else
          found += item.value if item?.value
      found
      
exports.swah = swah