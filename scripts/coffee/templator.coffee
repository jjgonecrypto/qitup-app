sp = getSpotifyApi 1

process = (view, params) ->
  template = sp.core.readFile(view).replace(/\r|\n/g, () -> "\\\n").replace /'/g, () -> "\\'"
  fncText = template.replace /#{.+?}/g, (found) ->
    "'+"+found.substr(2, found.length-3)+"+'"
  fnc = new Function "obj", "with(obj){ return \'#{fncText}\'; }"
  fnc(params) 
   
exports.process = process