require "rack"
require "middleman/rack"
require "rack/contrib/try_static"
require 'rack/reverse_proxy'

# Build the static site when the app boots
# `bundle exec middleman build`

# Enable proper HEAD responses
use Rack::Head
# Attempt to serve static HTML files
use Rack::TryStatic,
    :root => "tmp",
    :urls => %w[/],
    :try => ['.html', 'index.html', '/index.html']

use Rack::ReverseProxy do
  reverse_proxy_options :preserve_host => true
  reverse_proxy '/tutorials/', 'http://tutorials.jumpstartlab.com'
end

# Serve a 404 page if all else fails
run lambda{ |env|
  not_found_page = File.expand_path("../build/404.html", __FILE__)
  if File.exist?(not_found_page)
    [ 404, { 'Content-Type'  => 'text/html'}, [File.read(not_found_page)] ]
  else
    [ 404, { 'Content-Type'  => 'text/html' }, ['404 - page not found'] ]
  end
}
