module.exports = Ember.ArrayController.extend
  sortProperties: [ 'id' ]
  addStation: ->
    # find the highest id already
    ids = @mapProperty('id')# (i) -> parseInt(i.get 'id')
    max = _.max(ids)

    station = Ember.Object.create
      id: "#{max + 1}"
      name: "Station #{max + 1}"
      creating: true
      editing: true
      stationsRef: @get('content').get('stationsRef')
      stations: @

    @get('content').pushObject station
