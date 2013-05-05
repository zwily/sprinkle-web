module.exports = Ember.Route.extend
  redirect: ->
    @modelFor('application').get('firebaseAuth').logout()
    @transitionTo 'login'
