require 'rubygems'
require 'sinatra/base'
require 'slim'
require 'coffee-script'
require 'json'
require 'feldtruby'
require 'feldtruby/array'
require 'feldtruby/optimize/differential_evolution'
require 'feldtruby/optimize/problems/multi_objective_problems'
require 'pp'

# Run an optimizer in a thread that we can control from the outside with
# play, stop and pause commands.
class RestartableOptimizer
  attr_reader :optimizer, :mode, :exception

  def initialize(objective, dimensions, numStepsBeforeRestart = 1e50,
    verbose = false, optimizer = FeldtRuby::Optimize::DEOptimizer_Rand_1_Bin)
    @objective, @dimensions, @num_steps_before_restart = objective, dimensions, numStepsBeforeRestart
    @optimizer = optimizer
    @objective.dimensions = dimensions if @objective.respond_to?(:dimensions=)
    @ss = objective.search_space
    @optimizer = optimizer.new(@objective, @ss, {:verbose => verbose, :maxNumSteps => numStepsBeforeRestart})
    self.pause
    @thread = Thread.new do
      begin
        while true
          if @mode == :play
            @optimizer.optimize_num_steps(100) 
          else
            sleep 0.10 # Sleep while pausing so we don't take all CPU...
          end
        end
      rescue Exception => e
        @exception = e
      end
    end
  end

  def play
    @mode = :play
    @thread.run
  end

  def pause
    @mode = :pause
  end

  def stop
    @mode = :stop
    @thread.stop if @thread.alive?
  end
end

# Lets optimize a 5-D OmniTest objective introduced by Deb et al. 
# Allow very many steps before the search terminates => essentially it 
# will go on for ever. We have not yet started it though.
OptimizerController = RestartableOptimizer.new(MinOmniTest.new, 5, 1e100)

class CoffeeEngine < Sinatra::Base
  
  set :views,   File.dirname(__FILE__)    + '/coffee'
  
  get "/coffee/*.js" do
    filename = params[:splat].first
    coffee filename.to_sym
  end
  
end

require File.join(".", File.dirname(__FILE__), "brownian_searcher")
BrownianSearcher = BrownianMotion2DSearch.new(10, 0.5)
Thread.new {BrownianSearcher.start_search}

# A fake fitness data generator
class FakeFitnessData
  def initialize(numData = 10, numFitnesses = 2, minFitness = 0.0, maxFitness = 1.0)
    @next_id = 0
    @num_data = numData
    @num_fitness, @min, @max = numFitnesses, minFitness, maxFitness
    @delta = @max - @min
    @data = Array.new(@num_data).map {gen_new_data}
  end

  def new_fitness_value
    @min + rand() * @delta
  end

  # Every access we randomly do some changes to the data to fake evolution...
  def data
    update_data
    @data
  end

  def update_data
    @data = @data.map do |d|
      (rand() < 0.05) ? gen_new_data() : d
    end
  end

  def gen_new_data
    subqs = Array.new(@num_fitness).map {new_fitness_value}
    qv = subqs.mean
    {"v" => qv, "fs" => subqs, "id" => (@next_id += 1)}
  end
end

FitnessData = FakeFitnessData.new(50,2)

# The data engine should return the json or csv formatted data
# that is used in your app. You need to set this up to dynamically deliver the
# latest data about your running Ruby app/process/server.
class DataEngine < Sinatra::Base
  module SendAsJson
    def json_response(data)
      content_type :json
      data.to_json
    end
  end

  module SendAsCSV
    def csv_response(data, keys)
      content_type "application/octet-stream"
      str = keys.join(",") + "\n"
      data.each do |entry|
        str << (keys.map {|key| entry.send(key).to_s}.join(",") + "\n")
      end
      str
    end
  end

  helpers SendAsJson, SendAsCSV

  # Static data files are served from the "/data" dir
  set :views,   File.dirname(__FILE__)    + '/data'

  # Example handler that returns a random json data set for all example requests...
  get %r{/data/randints/arrayofsize([\d]+).json} do |size|
    a = Array.new(size.to_i).map {-5+(10*rand()).to_i}
    #json_response a.uniq.sort
    b = a.uniq.sort.map {|v| {"value" => v}}
    json_response b
  end

  get '/data/brownian_search/search_info.json' do
    json_response BrownianSearcher.search_info
  end

  get '/data/brownian_search/top_list.json' do
    json_response BrownianSearcher.search_info["top_list"]
  end

  get '/data/brownian_search/current_position.json' do
    json_response BrownianSearcher.pos
  end

  get %r{/data/brownian_search/all_positions_from_(\d+).json} do |fromIndex|
    json_response BrownianSearcher.all_positions(fromIndex.to_i)
  end

  get "/data/test/all_positions_from_0.csv" do
    positions = BrownianSearcher.all_positions(0)
    puts "Returning csv of #{positions.length} positions"
    csv_response positions, [:date, :delay, :distance, :origin, :destination]
  end

  get "/data/scatter.json" do
    json_response FitnessData.data
  end

  get "/data/optimization/archive.json" do
    a = OptimizerController.optimizer.archive
    #puts a.all_candidates.inspect
    json_response a.all_candidates
  end

  get %r{/data/optimization/controller/(.+)\.json} do |command|
    case command
    when "play"
      OptimizerController.play
    when "pause"
      OptimizerController.pause
    when "stop"
      OptimizerController.stop
    when "status"
      # Do nothing so we just return the current state below...
    else
      puts "ERROR: Don't know how to handle command #{command}"
    end
    # Respond with current controller mode and step of the optimizer.
    o = OptimizerController.optimizer
    res = {
      "mode" => OptimizerController.mode.to_s, 
      "step" => o.num_optimization_steps,
      "exception" => OptimizerController.exception
    }
    puts res.inspect
    json_response res
  end

end

class SwagrGuiServerExample < Sinatra::Base

  enable :logging
  disable :dump_errors

  use DataEngine
  use CoffeeEngine

  set :views,         File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/static'

#  get '/example_data.json' do
#    content_type :json
#    [-1, 2, 4, -7, -9].to_json
#  end
  
  get '/' do
    slim :index
  end

  get '/src' do
    slim :src
  end

  get '/test' do
    slim :src
  end

  get '/search' do
    slim :search
  end

  get '/traits' do
    slim :traits
  end

  get '/generators' do
    slim :generators
  end

  get '/about' do
    slim :about
  end

  def copyright_holders
    "FIXME: Your Name(s)..."
  end
  
  # Set the first year you started working on this app. The copyright will then go from then to current year.
  def first_year
    2012
  end

  def year
    current_year = Time.now.year
    if current_year != first_year
      "#{first_year}-#{current_year}"
    else
      "#{first_year}"
    end
  end

end

if __FILE__ == $0
  SwagrGuiServerExample.run! :port => 4000
end
