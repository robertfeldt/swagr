require 'rubygems'
require 'sinatra/base'
require 'slim'
require 'coffee-script'
require 'json'
require 'feldtruby'

class CoffeeEngine < Sinatra::Base
  
  set :views,   File.dirname(__FILE__)    + '/coffee'
  
  get "/coffee/*.js" do
    filename = params[:splat].first
    coffee filename.to_sym
  end
  
end

require File.join(".", File.dirname(__FILE__), "brownian_searcher")
BrownianSearcher = BrownianMotion2DSearch.new(5, 0.5)
Thread.new {BrownianSearcher.start_search}

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
    json_response [
      {"x" => 0, "y" => 0, "subqs" => [0.030, 0.12]},
      {"x" => 1, "y" => 1, "subqs" => [0.050, 0.06]},
      {"x" => 0, "y" => 1, "subqs" => [0.010, 0.12]},
      {"x" => 1, "y" => 0, "subqs" => [0.040, 0.06]}
    ]
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

  get '/edit' do
    slim :edit
  end

  get '/explore' do
    slim :explore
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
