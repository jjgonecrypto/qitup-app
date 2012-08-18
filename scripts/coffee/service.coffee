class Service
  reset: () ->
    @cache = {}
    @ignore = []
    @onDeauth = undefined
    @authenticated = false
    @criteria = {}

  constructor: (@service = {}) ->
    @reset()
    @criteria = service.criteria if service.criteria

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

  search: (next) ->
    @service.search
    

  message: (post, text, done) ->
    #call implementation to msg 
    #on success ->
      #add to ignore
      #done() 
    #on error ->
      #done err

exports.Service = Service