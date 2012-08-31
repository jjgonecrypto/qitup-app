class Service
  reset: () ->
    @cache = {}
    @ignore = {}
    @onDeauth = undefined
    @authenticated = false
    @criteria = {}
    @endpoints = []
    @last = {}

  constructor: (@service = {}) ->
    @reset()
    @criteria = @service.criteria if @service.criteria

  authenticate: (done, onDeauth) ->
    @onDeauth = onDeauth
    @doAuthenticate (result, err) =>
      return done null, err if err
      @authenticated = true
      done result

  logout: (done) -> 
    #perhaps this shouldn't have a done() callback but rather triggers onDeauth
    return done() if !@authenticated
    @doLogout (err) =>
      return done err if err
      @authenticated = false
      done()

  setCriteria: (criteria) ->
    criteria.timestamp = new Date() 
    @doGenerateEndpointsFrom criteria
    @criteria = criteria

  getCriteria: () -> @criteria

  lastId: (uri, id) ->
    @last[uri] = id if id
    @last[uri]

  search: (next) ->
    throw "no criteria set" if !@criteria
    @doSearch (result) => 
      return console.log "cached - ignoring" if cached.call @, result
      return console.log "past - ignoring" if past.call @, result
      return console.log "on ignore list" if ignored.call @, result

      next result, @
    
  message: (post, text, done) ->
    return done "cannot send message, not authenticated" if !@authenticated
    @doMessage post, text, (result, err) =>
      return done err if err
      ignore.call @, result
      done()

  cached = (result) -> 
    status = @cache[result.id]?
    @cache[result.id]?= result
    status

  past = (result) ->
    result.created instanceof Date and @criteria.future and result.created < @criteria.timestamp

  ignore = (result) -> @ignore[result.id] = result

  ignored = (result) -> @ignore[result.id]?

exports.Service = Service