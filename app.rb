require 'net/https'

require 'rubygems'
require 'nokogiri'
require 'sinatra'
require 'haml'
require 'sass'
require 'dalli'
require 'builder'

require 'change'
require 'parser'
require 'fetcher'

# UTF-8
$KCODE = 'u' if RUBY_VERSION < '1.9'
before do
  content_type :html, 'charset' => 'utf-8'
end

def fetch_changes!
  begin
    c = Fichte::Fetcher.run!
  rescue Timeout::Error
    puts "t/o"
  else
    settings.cache.set 'changes', Marshal.dump(c)
  end
end

Thread.new do
  loop do
    begin
      puts "fetching"
      fetch_changes!
      puts "done"
      
    rescue Exception => e
      puts e.inspect
    end
    
    sleep 60
  end
end




helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def view name
    File.read(File.join(File.dirname(__FILE__), "views", "#{name}.haml"))
  end
  
  def load_changes!
    @changes = Marshal.load settings.cache.get 'changes'
    
    raise "Fail. Memcache key 'changes' not set" unless @changes

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

configure do
  set :cache, Dalli::Client.new
end

get '/cachetest' do
  settings.cache.set('color', 'blue')
  settings.cache.get('color')
end

get '/stylesheets/screen.css' do
  sass File.read(File.join(File.dirname(__FILE__), "views", "style.sass"))
end

get '/' do
  load_changes!
  haml view("index"), :layout => view("layout")
end

get '/changes.json' do
  load_changes!  
  @changes.to_json
end

get '/changes.rss' do
  load_changes!
  builder File.read(File.join(File.dirname(__FILE__), "views", "rss.builder"))
end

