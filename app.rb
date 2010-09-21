require "rubygems"
require "nokogiri"

require 'net/https'
require 'sinatra'
require 'haml'


$KCODE = 'u' if RUBY_VERSION < '1.9'

before do
  content_type :html, 'charset' => 'utf-8'
end

class Fichte
  class Change < ::Struct.new(:id, :type, :date, :lesson, :old_subject, :new_subject, :old_teacher, :new_teacher, :form, :form2, :old_room, :new_room, :statistic, :moved_from, :moved_to, :unt_text, :text, :dropped)
      
  end
  
  def self.fetch
    url = URI.parse 'https://www.fichteportfolio.de/anzeige/subst_001.htm'
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    request = Net::HTTP::Get.new(url.path)
    response = http.request(request)
    
    doc = Nokogiri::HTML(response.body)
    
    
    
    
    doc.css("tr:not(:first-child)").map do |row|
      Change.new *row.css("td").map{|c|c.text.gsub("\302\240", "")}[0..16]
    end
  end
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