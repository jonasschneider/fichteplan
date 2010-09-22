require 'net/https'

require 'rubygems'
require 'nokogiri'
require 'sinatra'
require 'haml'
require 'sass'


# UTF-8
$KCODE = 'u' if RUBY_VERSION < '1.9'
before do
  content_type :html, 'charset' => 'utf-8'
end


class Fichte
  class Change < ::Struct.new(:id, :type_text, :date, :lesson, :old_subject, :new_subject, :old_teacher, :new_teacher, :form, :form2, :old_room, :new_room, :statistic, :moved_from, :moved_to, :unt_text, :text, :dropped)
    
    class AssertionFailed < Exception; end
    
    def assert(condition)
      raise AssertionFailed unless condition
    end
    
    def type
      case type_text
      when "Entfall"
        assert new_room == '---'
        assert new_subject == '---'
        assert new_teacher == '---'
        :entfall
      when "Raum-Vtr."
        assert new_room != old_room
        assert new_subject == old_subject
        assert new_teacher == old_teacher
        :raum
      when "Vertretung"
        assert new_teacher != old_teacher
        :vertretung
      when "Betreuung"
        :betreuung
      when "Verlegung"
        assert !moved_from.empty? || !moved_to.empty?
        :verlegung
      when "Tausch"
        :tausch
      else
        :dunno
      end
    rescue AssertionFailed
      :dunno
    end
  end
  
  def self.fetch
    base = 'https://www.fichteportfolio.de/anzeige/'
    next_page = 'subst_001.htm'
    done = %w()
    
    changes = [] 
    while !next_page.nil?
      puts "fetching #{next_page}"
      url = URI.parse base + next_page
      
      done << next_page
      next_page = nil
      
      
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      request = Net::HTTP::Get.new(url.path)
      response = http.request(request)
      
      
      doc = Nokogiri::HTML(response.body)
      
      if next_page_link = doc.css("meta[http-equiv=\"refresh\"]").first
        next_page_name = next_page_link['content'].gsub('9; URL=', '')
        next_page = next_page_name unless done.include? next_page_name
      end
      
      
      changes << doc.css("tr:not(:first-child)").map do |row|
        Change.new *row.css("td").map{|c|c.text.gsub("\302\240", "")}[0..16]
      end
    end
    
    changes.flatten
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