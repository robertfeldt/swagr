root = exports ? window
root.Swagr = if root.Swagr then root.Swagr else {}

# Assumes d3graph.coffee has been required before this one...
class root.Swagr.UpdatingTextGraph extends root.Swagr.D3Graph
  _transform_string: -> "translate(16," + (@opts.height / 2) + ")"

  _join_data: (data) -> @svg.selectAll("text").data(data, (d) -> d)

  _update_existing_elements: (text) ->
    @elems.attr("class", "update")
        .text(@textmapper(@elems, @data))
        .transition()
        .duration(@opts.transition_time)
        .attr("x", @xmapper(@elems, @data))

  _enter_new_elements: (text) ->
    @elems.enter().append("text")
        .attr("class", "enter")
        .attr("dy", ".35em")
        .attr("y", -@opts.transition_y_distance)
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
        .attr("y", @opts.transition_y_distance)
        .style("fill-opacity", 1e-6)
        .remove()

  xmapper: (elems, data) -> (d,i) -> i * 70

  textmapper: (elems, data) -> (d,i) -> 
    d + ( if (i+1 isnt data.length) then "," else "" )