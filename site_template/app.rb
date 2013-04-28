require 'sinatra/base'
require 'slim'
require 'coffee-script'
require 'json'

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

SiteName = "Swagr"

get "/coffee/*.js" do

	filename = params[:splat].first

	coffee "public/coffee/#{filename}".to_sym

end

get '/' do

	@page_title = "Swagr Basic Template"
	@stylesheet = "index"
	
	# This way we can load seperate javascript websocket client code specific to each route.
	#
	# For example the '/chat' route will need to have different client code and therefore we can load chat.js by
	# specifing @webSocketHandler = "chat"
	@web_socket_handler = "websocket_index"

	slim :index
end

# Catch all other urls and assume they are slim templates in views...
get /(.+)/ do |url|
	@page_title = url
	@stylesheet = "index"
	slim "#{url}".to_sym
end