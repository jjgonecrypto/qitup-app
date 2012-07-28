sp = getSpotifyApi 1

#borrowed from underscore ;)
escapes = 
  '\\':   '\\'
  "'":    "'"
  r:      '\r'
  n:      '\n'
  t:      '\t'
  u2028:  '\u2028'
  u2029:  '\u2029'

escaper = /\\|'|\r|\n|\t|\u2028|\u2029/g

process = (view, params) ->
  template = sp.core.readFile(view).replace /\r|\n/g, () -> "\\\n"
  template = template.replace /'/g, () -> "\\'"
  fncText = template.replace /#{.+?}/g, (found) ->
    "'+"+found.substr(2, found.length-3)+"+'"
  
  
  fnc = new Function "obj", "with(obj){ return \'#{fncText}\'; }"
  fnc(params) 
   
  #doc = document.implementation.createDocument 'http://www.w3.org/1999/xhtml', 'html',  null
  #doc.documentElement.innerHTML = sp.core.readFile(view)

exports.process = process