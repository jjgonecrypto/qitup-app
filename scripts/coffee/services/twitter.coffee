sp = getSpotifyApi 1

Service = sp.require("/scripts/js/service").Service

exports.service = new Service 
  url: #....


