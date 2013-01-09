require 'rubygems'
require 'sinatra/base'
require 'slim'
require 'sass'
require 'coffee-script'

class SassEngine < Sinatra::Base
  
  set :views,   File.dirname(__FILE__)    + '/sass'
  
  get '/sass/*.css' do
    sass params[:splat].first.to_sym
  end
  
end

class CoffeeEngine < Sinatra::Base
  
  set :views,   File.dirname(__FILE__)    + '/coffee'
  
  get "/coffeescript/*.js" do
    filename = params[:splat].first
    coffee filename.to_sym
  end
  
end

class WAppGuiServer < Sinatra::Base

  enable :logging
  disable :dump_errors

  use SassEngine
  use CoffeeEngine

  set :views,         File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'
  
  get '/' do
    slim :index
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
  WAppGuiServer.run! :port => 4000
end
