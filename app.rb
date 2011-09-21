require 'net/https'

require 'rubygems'
require 'nokogiri'
require 'sinatra'
require 'haml'
require 'sass'

require 'change'
require 'parser'
require 'fetcher'

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

get '/dry' do
  require 'fakeweb'
  
  FakeWeb.register_uri(:get, "https://www.fichteportfolio.de/anzeige/subst_001.htm", :body => File.read(File.join(File.dirname(__FILE__), "spec", "fixtures", "parsethis.html")))
  FakeWeb.register_uri(:get, "https://www.fichteportfolio.de/anzeige/subst_002.htm", :body => File.read(File.join(File.dirname(__FILE__), "spec", "fixtures", "parsethis2.html")))
  @changes = Fichte::Fetcher.run!
  FakeWeb.clean_registry
  
  haml view("index"), :layout => view("layout")
end

get '/dry.json' do
  require 'fakeweb'
  
  FakeWeb.register_uri(:get, "https://www.fichteportfolio.de/anzeige/subst_001.htm", :body => File.read(File.join(File.dirname(__FILE__), "spec", "fixtures", "parsethis.html")))
  FakeWeb.register_uri(:get, "https://www.fichteportfolio.de/anzeige/subst_002.htm", :body => File.read(File.join(File.dirname(__FILE__), "spec", "fixtures", "parsethis2.html")))
  @changes = Fichte::Fetcher.run!
  FakeWeb.clean_registry
  
  @changes.to_json
end

