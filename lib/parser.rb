require 'nokogiri'
require 'fichte'

class Fichte::Parser
  def initialize data = ''
    @data = data
  end
  
  def rows
    doc = Nokogiri::HTML.parse(@data)
    
    doc.css("tr:not(:first-child)").map do |row|
      row.css("td").map do |cell|
        txt = cell.text.gsub("\302\240", "")
        if txt.empty? || txt == '---'
          nil
        else
          txt
        end
      end
    end
  end
  
  def row_to_params row
    keys = %w(num stunde neues_fach vertretung raum detail altes_fach klasse).map{|v|v.to_sym}
    params = {}
    raise if row.length != keys.length
    row.each_with_index do |val, i|
      params[keys[i]] = val.match(/^\d+$/) ? val.to_i : val
    end
    params
  end
  
  def self.fetch
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
        
        #if next_page_link = doc.css("meta[http-equiv=\"refresh\"]").first
    #  next_page_name = next_page_link['content'].gsub('9; URL=', '')
    #  next_page = next_page_name unless done.include? next_page_name
    #end


        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(url.path)
        response = http.request(request)

        changes << self.extract(response.body)


      end

      changes.flatten
    end
  end
end