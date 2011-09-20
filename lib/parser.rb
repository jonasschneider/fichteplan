class Fichte

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
  
  def self.extract(html)
    doc = Nokogiri::HTML(html)
      
  
    if next_page_link = doc.css("meta[http-equiv=\"refresh\"]").first
      next_page_name = next_page_link['content'].gsub('9; URL=', '')
      next_page = next_page_name unless done.include? next_page_name
    end
    
    
    doc.css("tr:not(:first-child)").map do |row|
      Change.new *row.css("td").map{|c|c.text.gsub("\302\240", "")}[0..16]
    end
  end
end