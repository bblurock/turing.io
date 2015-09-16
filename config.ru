require 'rack'
require 'middleman/rack'
require 'rack/contrib/try_static'
require 'rack/rewrite'
require 'honeybadger'
# Build the static site when the app boots
# `bundle exec middleman build`

# Enable proper HEAD responses
use Rack::Head

# Attempt to serve static HTML files
use Rack::TryStatic,
    root: 'tmp',
    urls: %w(/),
    try:  %w(.html index.html /index.html)

REDIRECTS = {
 '/slides'    => 'https://www.dropbox.com/sh/d1891mc6ssx7izc/AAACqGgZ8qeltor7L3R_coZIa?dl=0',
 '/warrior'   => 'http://tutorials.jumpstartlab.com/projects/ruby_warrior.html',
 '/community' => 'http://www.meetup.com/Turing-Community-Events',
 '/jcasimir'  => 'https://jcasimir.youcanbook.me',
 '/jtellez'   => 'https://jtellez.youcanbook.me',
 '/steve'     => 'https://stevekinney.youcanbook.me',
 '/brand'     => 'http://brandfolder.com/turing',
 '/logo'      => 'http://brandfolder.com/turing',
 '/blog'      => 'http://blog.turing.io',
 '/hiring'    => 'http://people.turing.io'
}

use Rack::Rewrite do
  REDIRECTS.each { |from, to| found from, to }
end

# Configure and start Honeybadger
honeybadger_config = Honeybadger::Config.new(env: ENV['RACK_ENV'])
Honeybadger.start(honeybadger_config)

# And use Honeybadger's rack middleware
use Honeybadger::Rack::ErrorNotifier, honeybadger_config
use Honeybadger::Rack::MetricsReporter, honeybadger_config

# Serve a 404 page if all else fails
run lambda{ |env|
  not_found_page = File.expand_path('../build/404.html', __FILE__)
  if File.exist?(not_found_page)
    [ 404, { 'Content-Type'  => 'text/html'}, [File.read(not_found_page)] ]
  else
    [ 404, { 'Content-Type'  => 'text/html' }, ['404 - page not found'] ]
  end
}
