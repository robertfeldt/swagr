root = exports ? window
root.Swagr = if root.Swagr then root.Swagr else {}

class root.Swagr.UpdatingScatterplot extends root.Swagr.D3Graph
  default_options =
    width:                  400
    height:                 400
    xpos:                   0
    ypos:                   0
    left_pad:               60
    pad:                    20
    opacity:                0.70
    radius:                 6
    stroke_width:           1.25
    color_range:            colorbrewer.RdYlGn[11]
    transition_y:           30
    transition_x:           30
    transition_time:        1000              # milliseconds in each transition
    idfunc:                 ((d) -> d.id)
    xfunc:                  ((d) -> d.x)
    yfunc:                  ((d) -> d.y)
    colorvaluefunc:         ((d) -> d.v)
    update_interval:        2.0
    datamapper:             ((d) -> d)        # Default is the identity function, i.e. data is used as is. Override for filtering etc.
    tooltipmapper:          ((d) -> "id: " + d.id)

  constructor: (@selector, @dataUrl, opts = {}) ->
    @opts = @set_default_options_unless_given(opts, default_options)
    @_append_elements()
    @_setup()
    @update()     # First update so we have something to show...

  _transform_string: -> "translate(" + @opts.xpos + "," + @opts.ypos + ")"

  _setup: ->
    @xscale = d3.scale.linear().domain([0.0, 2.0]).range([@opts.left_pad, @opts.width-@opts.pad])
    @xAxis = d3.svg.axis().scale(@xscale).orient("bottom")
      .ticks(4)
      .tickFormat(((d,i) -> d.toPrecision(3)))

    @yscale = d3.scale.linear().domain([2.0, 0.0]).range([@opts.pad, @opts.height-@opts.pad*2])
    @yAxis = d3.svg.axis().scale(@yscale).orient("left")
      .ticks(4)
      .tickFormat(((d,i) -> d.toPrecision(3)))

    @svg.append("svg:g")
      .attr("class", "x axis")
      .attr("transform", "translate(0, "+(@opts.height-@opts.pad)+")")
      .call(@xAxis)

    @svg.append("svg:g")
      .attr("class", "y axis")
      .attr("transform", "translate("+(@opts.left_pad-@opts.pad)+", 0)")
      .call(@yAxis)

    @colorscale = d3.scale.quantize()
      .range(colorbrewer.RdYlGn[11])

    @tooltip = d3.select("body").append("div")   
    .attr("class", "tooltip")               
    .style("opacity", 0);

    #@tooltip = d3.select("body")
    #  .append("div")
    #  .style("position", "absolute")
    #  .style("z-index", "10")
    #  .style("visibility", "hidden")

  _join_data: (data) -> 
    idfunc = @opts.idfunc
    @svg.selectAll("circle").data(data, ((d) -> idfunc(d)))

  # Scales adapt to the min and max values of the current data.
  _update_scales: (data) ->
    @xscale.domain(d3.extent(data, @opts.xfunc))
    # High y is up so invert scale:
    @yscale.domain(d3.extent(data, @opts.yfunc).reverse())
    # Better to have low value and better is green so invert scale:
    @colorscale.domain(d3.extent(data, @opts.colorvaluefunc).reverse())

  # Now update the axes since the mins and maxs might have changed on the
  # scales
  _update_axes: (data) ->
    t = @svg.transition().duration(@opts.transition_time)
    t.select(".y.axis").call(@yAxis)
    t.select(".x.axis").call(@xAxis)

  _update_existing_elements: ->
    # Update scales and axes first to ensure things are later rendered with these
    # new ones.
    @_update_scales(@data)
    @_update_axes(@data)

  _update_new_and_existing_elements: ->
    @elems.attr("class", "circleupdate")
      .transition().duration(@opts.transition_time)
        .attr("r", @opts.radius)
        .attr("opacity", @opts.opacity)
        .attr("cx", ((d) => @xscale(@opts.xfunc(d))))
        .attr("cy", ((d) => @yscale(@opts.yfunc(d))))
        .attr("fill", ((d) => @colorscale(@opts.colorvaluefunc(d))))

  _enter_new_elements: =>
    @elems.enter().append("svg:circle").attr("class", "circleenter")
      .attr("cx", ((d) => @xscale(@opts.xfunc(d))+@opts.transition_x))
      .attr("cy", ((d) => @yscale(@opts.yfunc(d))-@opts.transition_y))
      .attr("r", 0)
      .attr("opacity", 1e-6)
      .attr("fill", ((d) => @colorscale(@opts.colorvaluefunc(d))))
      .attr("stroke", "black")
      .attr("stroke-width", @opts.stroke_width)
      .on("mouseover", ((d,i) => 
        @tooltip.transition().duration(100)
          .style("opacity", 0.80)
        @tooltip.html(@opts.tooltipmapper(d))
          .style("left", (d3.event.pageX+20) + "px")
          .style("top", (d3.event.pageY-20) + "px")))
      .on("mouseout", ((d,i) => 
        @tooltip.transition().duration(100)
          .style("opacity", 0)))

  _remove_exiting_elements: ->
    @elems.exit().attr("class", "circleexit")
      .transition().duration(@opts.transition_time)
        .attr("cx", ((d) => @xscale(@opts.xfunc(d))))
        .attr("cy", ((d) => @yscale(@opts.yfunc(d))))
        .attr("r", 0)
        .attr("opacity", 1e-6)
      .remove()
