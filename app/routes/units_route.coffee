module.exports = Ember.Route.extend

  maybeTransitionToUnit: (unit) ->
    unless @get '_didInitialTransition'
      @set '_didInitialTransition', true
      @transitionTo 'unit', unit

  model: ->
    userRef = @modelFor('application').get('firebaseUserRef')

    # There is a beautiful layer of abstraction just waiting to
    # be teased out of this awful code. I just haven't gone
    # looking for it yet. Beware what lies ahead.

    units = Ember.ArrayProxy.create({content: []})

    rootRef = App.firebaseRootRef
    userRef = @modelFor('application').get('firebaseUserRef')
    unitsRef = userRef.child('units')

    unitsRef.on 'child_added', (ss) =>
      unit = Ember.Object.create({id: ss.name()})


      # watch the unit
      unitRef = rootRef.child "/units/#{ss.name()}"
      unitRef.on 'value', (ss) ->
        unit.set 'name', ss.child('name').val()

      unitRef.child('/presence/unit-online').on 'value', (ss) ->
        unit.set 'unit-connected', ss.val()


      # watch the unit's stations
      stations = Ember.ArrayController.create
        content: []
        sortProperties: [ 'id' ]
      unit.set 'stations', stations

      stationsRef = unitRef.child '/stations'
      stations.set 'stationsRef', stationsRef

      stationsRef.on 'child_added', (ss) ->
        station = Ember.Object.create { id: parseInt(ss.name()) }
        stationRef = ss.ref()
        station.set 'stationRef', stationRef

        stationRef.on 'value', (ss) ->
          station.set 'name', ss.child('name').val()
          station.set 'real_state', ss.child('real_state').val()
          station.set 'desired_state', ss.child('desired_state').val()

        stations.pushObject station

      stationsRef.on 'child_removed', (ss) ->
        obj = stations.findProperty 'id', parseInt(ss.name())
        stations.removeObject(obj) if obj


      # watch the unit's programs
      programs = Ember.ArrayController.create({content: []})
      unit.set 'programs', programs

      programsRef = unitRef.child '/programs'
      programs.set 'ref', programsRef

      programsRef.on 'child_added', (ss) ->
        # watch the program
        program = Ember.Object.create { id: ss.name() }
        programRef = ss.ref()
        program.set 'ref', programRef

        programRef.child('/name').on 'value', (ss) ->
          program.set 'name', ss.val()

        programStations = Ember.ArrayController.create
          content: []
        program.set 'programStations', programStations

        programStationsRef = programRef.child '/stations'
        programStations.set 'ref', programStationsRef

        programStationsRef.on 'child_added', (ss, prevName) ->
          programStation = Ember.Object.create
            id: ss.name()
            station: parseInt(ss.child('station').val())
            duration: parseInt(ss.child('duration').val())
            program: program
            programStations: programStations

          # watch the program station, yadda yadda
          programStationRef = ss.ref()
          programStation.set 'ref', programStationRef

          programStationRef.on 'value', (ss) ->
            programStation.set 'station', parseInt(ss.child('station').val())
            programStation.set 'duration', parseInt(ss.child('duration').val())

          idx = 0
          if prevName
            prevStation = programStations.findProperty('id', prevName)
            idx = programStations.indexOf(prevStation) + 1
          programStations.insertAt(idx, programStation)

        programStationsRef.on 'child_removed', (ss) ->
          obj = programStations.findProperty 'id', ss.name()
          programStations.removeObject(obj) if obj

        programStationsRef.on 'child_moved', (ss, prevName) ->
          obj = programStations.findProperty 'id', ss.name()
          programStations.removeObject(obj) if obj

          idx = 0
          if prevName
            prevStation = programStations.findProperty('id', prevName)
            idx = programStations.indexOf(prevStation) + 1
          programStations.insertAt(idx, obj)


        programs.pushObject program

      programsRef.on 'child_removed', (ss) ->
        obj = programs.findProperty 'id', ss.name()
        programs.removeObject(obj) if obj


      units.pushObject unit
      @maybeTransitionToUnit unit

    unitsRef.on 'child_removed', (ss) ->
      obj = units.findProperty 'guid', ss.name()
      units.removeObject(obj) if (obj)

    units
