require 'date'

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Vertretungsplan"
    xml.description "Vertretungsplan des Fichte-Gymnasium Karlsruhe - Prototyp von Jonas Schneider, 2011."
    xml.link "http://fichteplan.heroku.com"

    @changes.each do |change|
      xml.item do
        xml.title "#{change.date} (#{change.klasse}): #{change.text}"
        xml.link "http://fichteplan.heroku.com"
        xml.pubDate DateTime.parse(change.date)
        xml.guid change.num
      end
    end
  end
end