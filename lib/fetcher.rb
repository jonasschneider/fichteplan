require 'fichte'
require 'parser'

class Fichte::Fetcher
  INTERVAL = 60
  
  def self.run!
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
      http.open_timeout = 10
      http.read_timeout = 15
      
      request = Net::HTTP::Get.new(url.path)
      
      request.add_field("User-Agent", "http://fichteplan.herokuapp.com - Vertretungsplan-Spider von Jonas Schneider")
      
      response = http.request(request)
      
      p = Fichte::Parser.new response.body
      
      next_page = p.next_page_name unless done.include? p.next_page_name
      
      changes << p.changes
    end

    changes.flatten
  end
end