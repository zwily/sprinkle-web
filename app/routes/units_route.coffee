module.exports = Ember.Route.extend

  maybeTransitionToUnit: (unit) ->
    unless @get '_didInitialTransition'
      @set '_didInitialTransition', true
      @transitionTo 'unit', unit

  model: ->
    userRef = @modelFor('application').get('firebaseUserRef')

    ## WOW - this could use some abstracting

    console.log('creating units firebase stuff')
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
      stations = Ember.ArrayController.create({content: []})
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
        program = Ember.Object.create { id: parseInt(ss.name()) }
        programRef = ss.ref()
        program.set 'ref', programRef

        programRef.on 'value', (ss) ->
          program.set 'name', ss.child('name').val()
          stationsAry = []
          ss.child('stations').forEach (sss) ->
            stationsAry.push sss.val()
            false
          program.set 'stations', stationsAry

        programs.pushObject program

      programsRef.on 'child_removed', (ss) ->
        obj = programs.findProperty 'id', parseInt(ss.name())
        programs.removeObject(obj) if obj


      units.pushObject unit
      @maybeTransitionToUnit unit

    unitsRef.on 'child_removed', (ss) ->
      obj = units.findProperty 'guid', ss.name()
      units.removeObject(obj) if (obj)

    units
