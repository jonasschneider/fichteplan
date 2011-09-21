require 'fichte'
require 'parser'

class Fichte::Fetcher
  def self.run!
    if ENV["LOCAL"]
      self.extract(File.read("subst_001.htm"))
    else

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
        
        p = Fichte::Parser.new response.body
        
        next_page = p.next_page_name unless done.include? p.next_page_name
        
        changes << p.changes

      end

      changes.flatten
    end
  end
end