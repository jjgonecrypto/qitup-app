matcher = sp.require "/scripts/js/matcher"
queuer = sp.require "/scripts/js/queuer"

class Channel 

  constructor: (@name, @options) ->
    @created = new Date()

  addService: (service) ->
    #each is an instance of either Twitter or Facebook, both extending from Service

  start: () -> 
    #start searching all services
    #setInterval
    if !@playlist
      @playlist = new models.Playlist()
      @playlistToSave = if @options.save_playlist then new models.Playlist "QItUp: " + @name else null
      queuer.reset()

    stopPolling()
    startPolling()
    queuer.turn on
    search()
    
  startPolling: () ->
    @interval = setInterval (() -> search), 30*1000

  stopPolling: () ->
    clearInterval @interval if @interval

  search: () ->
    #does all the heavy lifting


  stop: () ->
    stopPolling

  save: () ->
    #to localStorage - not implemened
  load: () -> 
    #from localStorage - not implemented

exports.Channel = Channel