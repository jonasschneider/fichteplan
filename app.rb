require "bundler/setup"
Bundler.require :default

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
    settings.cache.set 'changes_lastupdate', Time.new.to_i
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
    changes = settings.cache.get 'changes'
    
    raise "Fail. Memcache key 'changes' not set" unless changes
    
    @changes = Marshal.load changes
    
    filter = params[:filter] && params[:filter].split(',')

    if filter
      @changes.select! { |c| filter.include?(c.klasse) || filter.include?(c.base_klasse) }
    end
    
    @changes = @changes.sort_by {|c| [-c.date.to_i, c.stunde]}
    
    @last_updated = Time.at settings.cache.get 'changes_lastupdate'
  end
  
  # Usage: partial :foo
  def partial(page, options={})
    haml view(page), options.merge!(:layout => false)
  end
end

configure do
  set :cache, Dalli::Client.new
end

before do
  load_changes!
end

get '/' do
  haml view("index"), :layout => view("layout")
end

get '/changes.json' do
  @changes.to_json
end

get '/changes.rss' do
  builder File.read(File.join(File.dirname(__FILE__), "views", "rss.builder"))
end

get '/stylesheets/screen.css' do
  sass File.read(File.join(File.dirname(__FILE__), "views", "style.sass"))
end

get '/help' do
  haml view("help"), :layout => view("layout")
end