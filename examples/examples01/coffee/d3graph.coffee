root = exports ? window
root.Swagr = if root.Swagr then root.Swagr else {}

class root.Swagr.D3Graph
  default_options =
    width:                  960
    height:                 500
    xpos:                   0
    ypos:                   0
    update_interval:        1.5               # seconds between updates
    y_per_element:          25                # Difference per y position between consecutive elements
    x_per_element:          25                # Difference per x position between consecutive elements
    transition_y:           50
    transition_x:           50
    transition_time:        750               # milliseconds in each transition

  constructor: (@selector, @dataUrl, opts = {}) ->
    @opts = @set_default_options_unless_given(opts, default_options)
    @_append_elements()
    @_setup()
    @update()     # First update so we have something to show...

  _transform_string: -> "translate(" + @opts.xpos + "," + @opts.ypos + ")"

  _setup: ->
    # Do nothing for now but subclasses can override

  # Update the given options with the default options except when they have been
  # overridden.
  # There is probably an easier way to do this but my Coffeescript/Javascript
  # knowledge fails me...
  set_default_options_unless_given: (givenOpts, defaultOpts) ->
    for own option, value of defaultOpts
      givenOpts[option] = value unless givenOpts.hasOwnProperty(option)
    givenOpts

  # Append the svg to the top-level selector. Subclasses can add other elements as needed.
  _append_elements: () ->
    @svg = d3.select(@selector).append("svg")
                .attr("width", @opts.width)
                .attr("height", @opts.height)
              .append("g")
                .attr("transform", @_transform_string())

  # Start updating the graph
  start_updates: ->
    delay = @opts.update_interval*1000
    @interval_id = root.setInterval( (() => @update() ), delay )

  # Stop updating the graph
  stop_updates: -> root.clearInterval(@interval_id)

  # Run the updates for a given number of seconds
  run_updates_for: (seconds) ->
    @start_updates()
    setTimeout ( => @stop_updates(); console.log("Stopped updating graph!"); ), seconds*1000

  _update_new_and_existing_elements: ->
    # Do nothing

  _update_existing_elements: ->
    # Do nothing

  _enter_new_elements: ->
    # Do nothing

  _remove_exiting_elements: ->
    # Do nothing

  update: ->
    d3.json(@dataUrl, (error, data) =>
      @data = data
      # D3's general update pattern:
      # 1. DATA JOIN - Join new data with old elements, if any, then update, enter and exit below.
      @elems = @_join_data(data)
      # 2. UPDATE - Update existing elements as needed.
      @_update_existing_elements()
      # 3. ENTER - Create new elements as needed.
      @_enter_new_elements()
      # 4. UPDATE+ENTER - Operate on both the existing and new.
      @_update_new_and_existing_elements()      
      # 5. EXIT - Remove old elements as needed.
      @_remove_exiting_elements()
    )