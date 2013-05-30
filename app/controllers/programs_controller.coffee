module.exports = Ember.ArrayController.extend
  add: ->
    @get('content.ref').push
      name: 'New Program'
