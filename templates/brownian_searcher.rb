require 'json'

# Our dummy long-running ruby process is a Brownian motion where
# we are interested in the max distance from origo (0,0) that has been visited/found.
# Our GUI will present a top list of the top results found so far.
class BrownianMotion2DSearch
  # A position is an integer point in 2D space.
  Pos = Struct.new("Pos", :x, :y, :id)
  class Pos
    Origo = Pos.new(0,0,-1)

    def distance_to(pos)
      Math.sqrt( (pos.x - self.x)**2 + (pos.y - self.y)**2 )
    end
    
    def to_json(*a)
      {
        'x' => x,
        'y' => y,
        'id' => id,
        'distance' => self.distance_to(Origo)
      }.to_json(*a)
    end
  end

  attr_reader :num_steps, :pos

  def initialize(maxToplistLength = 10, maxSleepSeconds = 2.0)
    @max_top_list_length = maxToplistLength
    @max_sleep_seconds = maxSleepSeconds
    @num_steps = 0
    @pos = new_pos(0, 0)
    @top_list = [@pos]
  end

  def new_pos(x, y)
    Pos.new(x, y, @num_steps)
  end

  def start_search
    while true
      take_brownian_step()
      puts "Step = #{@num_steps}, at pos = #{@pos}"
      update_top_list()
      # Sleep so we are not searching all the time => simulate other long-running calcs...
      sleep( @max_sleep_seconds * rand() )
    end
  end

  # Return info about the search such as the number of steps taken and the current top list
  def search_info
    {"step" => @num_steps, "top_list" => @top_list}
  end

  def rand_unit_step
    rand() < 0.495 ? -1 : 1
  end

  def take_brownian_step
    @num_steps += 1
    @pos = new_pos(@pos.x + rand_unit_step(), @pos.y + rand_unit_step())
  end

  def update_top_list
    @top_list << @pos
    sort_top_list
    limit_top_list_length
  end

  def sort_top_list
    # Add a small value based on when the position was found (here: id) => older positions with same distance
    # are ranked higher than later found positions with same distance.
    @top_list = @top_list.sort_by {|p| -p.distance_to(Pos::Origo)+(p.id/(1000.0*@num_steps))}
  end

  def limit_top_list_length
    @top_list = @top_list.take(@max_top_list_length)
  end
end

if __FILE__ == $0
  s = BrownianMotion2DSearch.new
  Thread.new {s.start_search}
  require 'pp'
  Thread.new {
    while true
      sleep 5.0
      pp s.search_info
    end
  }
  sleep 20
  pp s.search_info
  exit -1
end