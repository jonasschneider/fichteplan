require 'net/https'

require 'rubygems'
require 'nokogiri'
require 'sinatra'
require 'haml'
require 'sass'

require 'change'
require 'parser'

# UTF-8
$KCODE = 'u' if RUBY_VERSION < '1.9'
before do
  content_type :html, 'charset' => 'utf-8'
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def view name
    File.read(File.join(File.dirname(__FILE__), "views", "#{name}.haml"))
  end
  
  # Usage: partial :foo
  def partial(page, options={})
    haml view(page), options.merge!(:layout => false)
  end
end

get '/stylesheets/screen.css' do
  sass File.read(File.join(File.dirname(__FILE__), "views", "style.sass"))
end

get '/' do
  p = Fichte::Parser.new File.read(File.join(File.dirname(__FILE__), "spec", "fixtures", "parsethis.html"))
  @changes = p.changes
  haml view("index"), :layout => view("layout")
end