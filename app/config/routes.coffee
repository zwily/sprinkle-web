App = require '../app'

App.Router.map ->
  @resource 'units', { path: "/units" }, ->
    @resource 'unit', { path: "/:unit_id" }
  @route 'login'
  @route 'logout'

App.Router.reopen
  location: 'none'

