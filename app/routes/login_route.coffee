module.exports = Ember.Route.extend
  model: ->
    Ember.Object.create
      username: ''
      password: ''
      authError: null
      authorizing: false
      remember: true

  events:
    authorize: ->
      model = @modelFor 'login'
      @modelFor('application').get('firebaseAuth').login 'password',
        email: model.get 'username'
        password: model.get 'password'
        rememberMe: model.get 'remember'
      model.set 'authorizing', true
