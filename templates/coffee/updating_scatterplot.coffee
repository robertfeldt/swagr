root = exports ? window
root.Swagr = if root.Swagr then root.Swagr else {}

# Assumes d3graph.coffee has been required before this one...
class root.Swagr.UpdatingScatterplot extends root.Swagr.D3Graph
  _transform_string: -> "translate(16," + (@opts.height / 2) + ")"

  _append_elements: () ->
    @svg = d3.select(@selector).append("svg")
                .attr("width", @opts.width)
                .attr("height", @opts.height)
              .append("g")
                .attr("transform", @_transform_string())

  _remove_existing_axes: () ->
    

  _append_axes: () ->


  _join_data: (data) -> 
    _remove_existing_axes()
    _append_axes(data)
    @svg.selectAll("circle").data(data)

  _update_existing_elements: (text) ->
    @elems.attr("class", "update")
        .text(@textmapper(@elems, @data))
        .transition()
        .duration(@opts.transition_time)
        .attr("x", @xmapper(@elems, @data))

  _enter_new_elements: (text) ->
        scatterplot.selectAll("circle")
          .data(data)
          .enter()
          .append("circle")
          .attr("cx", ((d) -> xscale(d.fs[0])))
          .attr("cy", ((d) -> yscale(d.fs[1])))
          .attr("opacity", 0.80)
          .attr("r", 6)
          .attr("fill", ((d) -> colorscale(d.v)))

    @elems.enter().append("circle")
          .attr("cx", ((d) -> xscale(d.fs[0])))
          .attr("cy", ((d) -> yscale(d.fs[1])))
          .attr("opacity", 0.80)
          .attr("r", 6)
          .attr("fill", ((d) -> colorscale(d.v)))

        .attr("class", "enter")
        .attr("dy", ".35em")
        .attr("y", -@opts.transition_y)
        .attr("x", @xmapper(@elems, @data))
        .style("fill-opacity", 1e-6)
        .text(@textmapper(@elems, @data))
        .transition()
        .duration(@opts.transition_time)
        .attr("y", 0)
        .style("fill-opacity", 1)

  _remove_exiting_elements: (text) ->
    @elems.exit()
        .attr("class", "exit")
        .transition()
        .duration(@opts.transition_time)
        .attr("y", @opts.transition_y)
        .style("fill-opacity", 1e-6)
        .remove()

  xmapper: (elems, data) => (d,i) => i * @opts.x_per_element

  textmapper: (elems, data) -> (d,i) -> 
    d.value + ( if (i+1 isnt data.length) then "," else "" )