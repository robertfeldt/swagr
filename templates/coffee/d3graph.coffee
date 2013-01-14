root = exports ? window
root.Swagr = if root.Swagr then root.Swagr else {}
class root.Swagr.D3Graph
  default_options =
    width:                  960
    height:                 500
    transition_y_distance:  50
    update_interval:        1.75              # seconds
    transition_time:        600               # milliseconds

  constructor: (@selector, @dataUrl, opts = {}) ->
    @opts = @set_default_options_unless_given(opts, default_options)
    @_append_svg()
    @update()     # First update so we have something to show...

  set_default_options_unless_given: (givenOpts, defaultOpts) ->
    for own option, value of defaultOpts
      givenOpts[option] = value unless givenOpts.hasOwnProperty(option)
    givenOpts

  # Append the svg to the top-level selector
  _append_svg: () ->
    @svg = d3.select(@selector).append("svg")
                .attr("width", @opts.width)
                .attr("height", @opts.height)
              .append("g")
                .attr("transform", @_transform_string())

  # Start updating the graph
  start_updates: ->
    @interval_id = root.setInterval ( => @update() ), @opts.update_interval*1000

  # Stop updating the graph
  stop_updates: -> root.clearInterval(@interval_id)

  # Run the updates for a given number of seconds
  run_updates_for: (seconds) ->
    @start_updates()
    setTimeout ( => @stop_updates(); console.log("Stopped updating graph!"); ), seconds*1000

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
      # 4. EXIT - Remove old elements as needed.
      @_remove_exiting_elements()
    )