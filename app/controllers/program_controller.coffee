module.exports = Ember.ObjectController.extend
  needs: ['unit']

  edit: ->
    @set 'editing', true

  doneEditing: ->
    # commit changes
    # TODO: commit changes as things are edited?
    programStations = @get 'programStations'

    @get('ref').child('/name').set @get('name')

    # update the priorities in a separate loop -
    # doing it during the main loop may mess up the iteration,
    # cause the firebase callback may fire immediately on priority
    # change, confusing the enumerator
    priorityUpdates = []

    programStations.forEach (programStation, index) ->
      ref = null
      if programStation.get 'creating'
        ref = programStations.get('ref').push
          station: programStation.get 'station'
          duration: programStation.get 'duration'

        # remove the placeholder we used to create, because
        # the op above just added the real one to firebase,
        # which will add it to the array
        programStations.removeObject programStation
      else
        ref = programStation.get 'ref'
        ref.child('/duration').set programStation.get('duration')

      priorityUpdates.push
        ref: ref
        priority: index

    for update in priorityUpdates
      update.ref.setPriority(update.priority)

    @set 'editing', false

  delete: ->
    if confirm "Are you sure you want to delete this program?"
      @get('ref').remove()

  addStation: ->
    # default to the station immediately following the last one in the list
    lastProgramStation = @get 'programStations.lastObject'
    stations = @get 'controllers.unit.stations'
    nextStation = stations.get 'firstObject'
    nextDuration = 300

    if lastProgramStation
      nextDuration = lastProgramStation.get 'duration'
      lastStation = stations.findProperty 'id', lastProgramStation.station
      lastStationIdx = stations.indexOf(lastStation)
      if lastStationIdx < stations.get('length') - 1
        nextStation = stations.objectAt lastStationIdx + 1

    newStation = Ember.Object.create
      creating: true
      station: nextStation.id
      duration: nextDuration
      program: @
      programStations: @get 'programStations'

    @get('programStations').pushObject newStation
