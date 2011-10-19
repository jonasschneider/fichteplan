require "bundler/setup"
Bundler.require :default

require 'change'
require 'parser'
require 'fetcher'
require 'date'

Thread.new do
  %x(ruby fetcher.rb)
end


# UTF-8
$KCODE = 'u' if RUBY_VERSION < '1.9'
before do
  content_type :html, 'charset' => 'utf-8'
end

Date::DAYNAMES = %w(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag)

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
      @changes.select! { |c| c.matches_filter? filter }
    end
    
    @changes = @changes.sort_by {|c| [-c.date.to_time.to_i, c.stunde]}
    
    @last_updated = Time.at(settings.cache.get 'changes_lastupdate').getlocal("+02:00")
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
  @is_up = (Time.now - @last_updated) / Fichte::Fetcher::INTERVAL < 5
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