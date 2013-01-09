require 'rubygems'
require 'sinatra/base'
require 'slim'
require 'coffee-script'

class CoffeeEngine < Sinatra::Base
  
  set :views,   File.dirname(__FILE__)    + '/assets/coffeescript'
  
  get "/javascripts/*.js" do
    filename = params[:splat].first
    coffee filename.to_sym
  end
  
end

class WAppGuiServer < Sinatra::Base

  use CoffeeEngine

  set :views,         File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'
  
  get '/' do
    slim :index
  end
  
end

if __FILE__ == $0
  WAppGuiServer.run! :port => 4000
end
