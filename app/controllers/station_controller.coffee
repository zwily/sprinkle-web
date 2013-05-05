module.exports = Ember.ObjectController.extend
  needs: ['unit']

  toggleStation: ->
    # if an action is pending, cancel it
    if @get 'desired_state'
      @get('stationRef').child('desired_state').remove()
      return

    # otherwise, request an opposite status of what's
    # current
    new_state = 'on'
    if @get('real_state') == "on"
      new_state = 'off'

    @get('stationRef').child('desired_state').set
      state: new_state
      username: App.firebaseUser.email
      device: 'Web'
      time: (new Date().getTime() / 1000)

  editStation: ->
    @set('editing', true)

  save: ->
    if @get 'creating'
      ref = @get('stationsRef').child(@get 'id')
      @set('stationRef', ref)
      @get('stations').removeObject(@get 'content')

    @get('stationRef').child('name').set(@get('name'))
    @set('editing', false)

  delete: ->
    if @get 'creating'
      @get('stations').removeObject(@get 'content')
    else
      if confirm "Are you sure you want to remove this station?"
        @get('stationRef').remove()

  isOn: (->
    @get('real_state') == "on"
  ).property('real_state')

  unitEditing: (->
    @get 'controllers.unit.editing'
  ).property 'controllers.unit.editing'
