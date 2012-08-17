class Service
  reset: () ->
    @cache = {}
    @ignore = []
    @onDeauth = undefined
    @authenticated = false
    @criteria = {}

  constructor: (@options = {}) ->
    @reset()
    @criteria = options.criteria if options.criteria

  authenticate: (done, onDeauth) ->
    @onDeauth = onDeauth
    #call implementation of auth
    #on err ->
      #done err
    #on success ->
      #authenticated = true
      #done()

  logout: (done) -> 
    #perhaps this shouldn't have a done() callback but rather triggers onDeauth


  setCriteria: (criteria) ->
    @criteria = criteria

  search: (next) ->
    #call search implementation....

    #(uses @criteria)

  message: (post, text, done) ->
    #call implementation to msg 
    #on success ->
      #add to ignore
      #done() 
    #on error ->
      #done err

exports.Service = Service