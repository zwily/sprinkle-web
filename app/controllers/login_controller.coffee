module.exports = Ember.ObjectController.extend
  needs: ['application']

  message: (->
    @get('controllers.application.authError')
  ).property 'controllers.application.authError'

