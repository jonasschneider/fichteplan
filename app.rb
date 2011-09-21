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
  
  def fetch_changes!
    if params[:dry]
      require 'fakeweb'
      FakeWeb.register_uri(:get, "https://www.fichteportfolio.de/anzeige/subst_001.htm", :body => File.read(File.join(File.dirname(__FILE__), "spec", "fixtures", "parsethis.html")))
      FakeWeb.register_uri(:get, "https://www.fichteportfolio.de/anzeige/subst_002.htm", :body => File.read(File.join(File.dirname(__FILE__), "spec", "fixtures", "parsethis2.html")))
      @changes = Fichte::Fetcher.run!
      FakeWeb.clean_registry
    else
      begin
        @changes = Fichte::Fetcher.run!
      rescue Timeout::Error
        halt haml "%h1 Timeout. Schulserver down?", :layout => view("layout")
      end
    end
    
    if params[:filter].kind_of? Array
      @changes.select! { |c| params[:filter].include? c.klasse }
    elsif params[:filter].kind_of? String
      @changes.select! { |c| c.klasse == params[:filter] }
    end
    
    @changes = @changes.sort_by {|c| [-c.date.to_i, c.stunde]}
    
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
  fetch_changes!
  haml view("index"), :layout => view("layout")
end

get '/changes.json' do
  fetch_changes!  
  @changes.to_json
end

get '/changes.rss' do
  fetch_changes!
  
  builder File.read(File.join(File.dirname(__FILE__), "views", "rss.builder"))
end

