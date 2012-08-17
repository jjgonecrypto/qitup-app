class Service
  constructor: (@options) ->
    @reset()

  reset: () ->
    @queryCache = {}
    @ignore = []
    @onDeauth = undefined
    @authenticated = false

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


  criteria: () ->
    #controls how the search should be for a channel

    #eg. 
      #facebook -
        #users: tiltnyc, justinjmoses
        #keywords: tiltcookout, tiltnyc
        #from_now: Date

      #twitter
        #users: tiltnyc
        #keywords: tiltnyc
        #from_now: Date  

  search: (next) ->
    #call search implementation....

  message: (post, text, done) ->
    #call implementation to msg 
    #on success ->
      #add to ignore
      #done() 
    #on error ->
      #done err

exports.Service = Service