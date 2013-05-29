module.exports = Ember.Route.extend
  model: ->
    Ember.Object.create
      firebaseAuth: null
      firebaseUserRef: null
      authError: null
      authUser: null

  activate: ->
    model = @modelFor 'application'

    # update current time every second, for those models that care
    setInterval ->
      model.set 'currentTime', new Date().getTime()
    , 1000

    ## TODO: Make firebase location configurable
    App.firebaseRootRef = new Firebase 'https://sprinkle.firebaseio.com/'
    Firebase.root = App.firebaseRootRef

    firebaseAuth = new FirebaseAuthClient App.firebaseRootRef, (error, user) =>
      console.log "error: #{error} user: #{user}"
      model.set 'authError', error
      model.set 'authUser', user
      App.firebaseUser = user
      model.set 'firebaseUserRef', null

      if error
        # the login failed for some reason, so don't attempt to continue
        return

      # the @transitionTo calls below need to be made the next
      # time around the run loop, because the app may be currently
      # booting and calling them immediately can confuse things.
      if user
        model.set 'firebaseUserRef', App.firebaseRootRef.child('/users/' + user.id)
        Ember.run.next @, ->
          @transitionTo 'units'
      else
        Ember.run.next @, ->
          @transitionTo 'login'

    @modelFor('application').set 'firebaseAuth', firebaseAuth

