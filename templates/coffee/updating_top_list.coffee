root = exports ? window
root.Swagr = if root.Swagr then root.Swagr else {}

# Assumes d3graph.coffee has been required before this one...
class root.Swagr.UpdatingToplist extends root.Swagr.D3Graph
  _transform_string: -> "translate(0,20)"

  _enter_new_elements: (text) ->
    @elems.enter().append("text")
        .attr("class", "enter")
        .attr("dx", ".35em")
        .attr("x", @opts.transition_x)
        .attr("y", @ymapper(@elems, @data))
        .style("fill-opacity", 1e-6)
        .text(@textmapper(@elems, @data))
        .transition()
        .duration(@opts.transition_time)
        .attr("x", 0)
        .style("fill-opacity", 1)

  _update_existing_elements: (text) ->
    @elems.attr("class", "update")
        .text(@textmapper(@elems, @data))
        .transition()
        .duration(@opts.transition_time)
        .attr("y", @ymapper(@elems, @data))

  _remove_exiting_elements: (text) ->
    @elems.exit()
        .attr("class", "exit")
        .transition()
        .duration(@opts.transition_time)
        .attr("y", (d, i) => @opts.height)
        .style("fill-opacity", 1e-6)
        .remove()

  ymapper: (elems, data) -> (d,i) -> i * 25

  textmapper: (elems, data) -> (d,i) -> d