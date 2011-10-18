require 'date'

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Vertretungsplan #{params[:filter] ? " gefiltert nach #{params[:filter]}" : ""}"
    xml.description "Vertretungsplan des Fichte-Gymnasium Karlsruhe - Prototyp von Jonas Schneider, 2011."
    xml.link "http://fichteplan.heroku.com#{params[:filter] ? "?filter=#{params[:filter]}" : ""}"

    @changes.each do |change|
      xml.item do
        xml.title "#{change.date} (#{change.klasse}): #{change.text}"
        xml.link "http://fichteplan.heroku.com"
        xml.pubDate change.date
        xml.guid change.num
      end
    end
  end
end