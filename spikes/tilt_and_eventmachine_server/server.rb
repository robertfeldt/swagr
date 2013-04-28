require 'tilt'
require 'slim'
require 'eventmachine'
require './thin_http_parser.rb'
require 'pp'

# Render web site files from their templates. Focus is on supporting slim
# and coffee for generating web sites (but other templates might work).
class RenderSite
  # Paths where we look for files.
  def initialize(*paths)
    @paths = paths

    # Cache maps url's to their already rendered content.
    @cache = Hash.new

    # Cache maps url's to the files from which they are rendered.
    @cache_files = Hash.new
  end

  # Render a url, surrounding it with a layout.
  def render(url, layout = "views/layout.slim", values = {})
    return @cache[url] if @cache.has_key?(url)
    url = "/index" if url == "/"
    output = if layout
      values[:insert_body] = render_template(url, self)
      render_template layout, self, values
    else
      render_template url, self, values
    end
    @cache[url] = output
  end

  # Render a template as is, i.e. without surrounding it with a layout.
  def render_template url, context = self, values = {}
    return @cache[url] if @cache.has_key?(url)
    file = find_file_from_url(url)
    return nil if file == nil
    @cache_files[url] = file
    puts "Now render #{file}"
    @cache[url] = Tilt.new(file).render context, values
  end

  def base_url(url)
    bname_parts = File.basename(url).split(".")
    if bname_parts.length > 1
      File.join(File.dirname(url), bname_parts[0...-1].join("."))
    else
      url
    end
  end

  def find_file_from_url url
    puts "1. Looking for #{url}"
    burl = base_url url
    puts "2. b_url = #{burl}"    
    @paths.each do |p|
      fp = File.join(p, url)
      puts "3. Looking for #{fp}"
      return fp if File.exist?(fp)

      if burl
        fp2 = File.join(p, burl) + ".*"
        puts "4. Looking for #{fp2}"
        file = Dir[fp2].first
        puts "5. file = #{file}"
        return file if file && File.exist?(file)
      end
    end
    return nil
  end

  def copyright_holders
    "FIXME: Your Name(s)..."
  end

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

# We give a preferred order for looking for files to render.
Renderer = RenderSite.new "../../examples/wiser_new/local_changes/views", "../../templates"
 
# Freeze some HTTP header names & values
KEEPALIVE = "Connection: Keep-Alive\r\n".freeze
 
class RequestHandler < EM::Connection
  def post_init
    @parser = RequestParser.new
  end
 
  def receive_data(data)
    handle_http_request if @parser.parse(data)
  end
 
  def send_our_data(data, code = 200)
    keep_alive = @parser.persistent?
    send_data("HTTP/1.1 #{code} OK\r\nContent-Type: text/html\r\nContent-Length: #{data.bytesize}\r\n#{ keep_alive  ? KEEPALIVE.clone : nil}\r\n#{data}")
  end

  def handle_http_request
    env = @parser.env
    h = {:env => env, :body => @parser.body.string}
    pp h
 
    if env["REQUEST_METHOD"] == "GET"
      data = Renderer.render env["REQUEST_URI"]
      if data
        send_our_data data, 200
      else
        send_our_data "ERROR!", 404
      end
    else
      send_our_data "OK"      
    end

    keep_alive = @parser.persistent?
    if keep_alive
      post_init
    else
      close_connection_after_writing
    end
  end
end
 
host,port = "0.0.0.0", 8083
puts "Starting server on #{host}:#{port}, #{EM::set_descriptor_table_size(32768)} sockets"
EM.run do
  EM.start_server host, port, RequestHandler
  if ARGV.size > 0
    forks = ARGV[0].to_i
    puts "... forking #{forks} times => #{2**forks} instances"
    forks.times { fork }
  end
end