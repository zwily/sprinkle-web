module.exports = Ember.ObjectController.extend
  needs: ['unit']
  stationModel: ->
    id = @get 'station'
    stations = @get 'controllers.unit.stations'
    stations.findProperty 'id', id
