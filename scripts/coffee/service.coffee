class Service
  reset: () ->
    @cache = {}
    @ignore = []
    @onDeauth = undefined
    @authenticated = false
    @criteria = {}

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
    @doLogout (result, err) =>
      return done null, err if err
      @authenticated = false
      done result

  setCriteria: (criteria) ->
    @criteria = criteria

  getCriteria: () -> @criteria

  search: (next) ->
    @service.search () -> 
      #cache result
      next()
    
  message: (post, text, done) ->
    @doMessage post, text, (err) ->
      return done err if err
      #add to ignore
      done()

exports.Service = Service