Ember.Handlebars.registerBoundHelper 'formatDuration', (value) ->
  # Just convert seconds to minutes for now
  "#{(value / 60)}m"
