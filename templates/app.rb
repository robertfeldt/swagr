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
  
end

if __FILE__ == $0
  WAppGuiServer.run! :port => 4000
end
