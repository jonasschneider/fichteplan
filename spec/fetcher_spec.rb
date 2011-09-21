require 'fakeweb'
require 'fetcher'

FakeWeb.allow_net_connect = false

describe 'Fetcher' do
  it 'works' do
    FakeWeb.register_uri(:get, "https://www.fichteportfolio.de/anzeige/subst_001.htm", :body => File.read(File.join(File.dirname(__FILE__), "fixtures", "parsethis.html")))
    FakeWeb.register_uri(:get, "https://www.fichteportfolio.de/anzeige/subst_002.htm", :body => File.read(File.join(File.dirname(__FILE__), "fixtures", "parsethis2.html")))
    
    c = Fichte::Fetcher.run!
    c.group_by{|c|c.date}.length.should == 2
    c.length.should == 50
  end
end