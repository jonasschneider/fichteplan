require 'net/https'

require 'rubygems'
require 'nokogiri'
require 'sinatra'
require 'haml'
require 'sass'

require 'change'

# UTF-8
$KCODE = 'u' if RUBY_VERSION < '1.9'
before do
  content_type :html, 'charset' => 'utf-8'
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  # Usage: partial :foo
  def partial(page, options={})
    haml page, options.merge!(:layout => false)
  end
end

get '/stylesheets/screen.css' do
  sass :style
end

get '/' do
  @changes = Fichte.fetch
  haml :index
end