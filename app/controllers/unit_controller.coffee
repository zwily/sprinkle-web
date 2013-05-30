_ = require 'vendor/underscore'

module.exports = Ember.ObjectController.extend
  edit: ->
    @set 'editing', true

  doneEditing: ->
    @set 'editing', false

  addStation: ->
    # find the highest id already
    ids = @get('stations').mapProperty('id')
    max = _.max(ids)

    station = Ember.Object.create
      id: "#{max + 1}"
      name: "Station #{max + 1}"
      creating: true
      editing: true
      stationsRef: @get 'stations.stationsRef'
      stations: @get 'stations'

    @get('stations.content').pushObject station
