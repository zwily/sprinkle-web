module.exports = Ember.ArrayController.extend
  multipleUnits: (->
    @get('length') > 1
  ).property('length')
