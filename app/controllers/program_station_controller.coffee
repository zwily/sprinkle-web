module.exports = Ember.ObjectController.extend
  needs: ['unit']

  first: (->
    @get('content') == @get('programStations.firstObject')
  ).property('programStations.firstObject')

  last: (->
    @get('content') == @get('programStations.lastObject')
  ).property('programStations.lastObject')

  durationMinutes: ((key, value) ->
    if arguments.length == 1
      secs = @get 'duration'
      if parseInt(secs) > 0
        return secs / 60
      else
        return 0
    else
      @set('duration', parseInt(value) * 60)
      return value
  ).property('duration')

  stationModel: (->
    id = @get 'station'
    stations = @get 'controllers.unit.stations'
    stations.findProperty 'id', id
  ).property('station')

  up: ->
    programStations = @get 'programStations'
    me = @get 'content'
    index = programStations.indexOf(me)
    programStations.removeAt(index)
    programStations.insertAt(index - 1, me)

  down: ->
    programStations = @get 'programStations'
    index = programStations.indexOf(@get 'content')
    programStations.removeObject(@get 'content')
    programStations.insertAt(index + 1, @get('content'))

  delete: ->
    if @get 'creating'
      @get('programStations').removeObject(@get 'content')
    else
      @get('ref').remove()
