module.exports = Ember.ObjectController.extend
  edit: ->
    @set 'editing', true

  doneEditing: ->
    @set 'editing', false
