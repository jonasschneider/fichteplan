require 'parser'

describe 'Parser' do
  describe '#rows' do
    it 'parses' do
      p = Fichte::Parser.new File.read(File.join(File.dirname(__FILE__), "fixtures", "parsethis.html"))
      p.rows[7].inspect.should == '["254", "5", "F2", "JÖR", "206", "statt Do. 2. Std", "M", "08c"]'
    end
    
    it 'ignores the MOTD' do
      p = Fichte::Parser.new File.read(File.join(File.dirname(__FILE__), "fixtures", "motd.html"))
      p.rows.length.should == 1
    end
  end
  
  describe '#row_to_params' do
    p = Fichte::Parser.new File.read(File.join(File.dirname(__FILE__), "fixtures", "parsethis.html"))
    p.row_to_params(["254", "5", "F2", "JÖR", "206", "statt Do. 2. Std", "M", "08c"]).should == { :num => 254, :stunde => 5, :neues_fach => "F2", :vertreter => "JÖR", :raum => 206, :detail => "statt Do. 2. Std", :altes_fach => "M", :klasse => "08c", :date => "21.9.2011" }
  end
  
  describe '#next_page_name' do
    it 'works' do
      p = Fichte::Parser.new File.read(File.join(File.dirname(__FILE__), "fixtures", "parsethis.html"))
      p.next_page_name.should == 'subst_002.htm'
    end
  end
  
  describe '#date' do
    it 'fetches date' do
      p = Fichte::Parser.new File.read(File.join(File.dirname(__FILE__), "fixtures", "parsethis.html"))
      p.date.should == "21.9.2011"
    end
  end
  
  describe '#split_forms' do
    it 'is a noop when there is only one form' do
      p = Fichte::Parser.new
      result = p.split_forms [{:klasse => "08c", :raum => 100}]
      result.should == [{:klasse => "08c", :raum => 100}]
    end
    
    it 'splits the entry when there are two forms' do
      p = Fichte::Parser.new
      result = p.split_forms [{:klasse => "08c, 07c", :raum => 100}]
      result.should == [{:klasse => "08c", :raum => 100}, {:klasse => "07c", :raum => 100}]
    end
  end
  
  describe '#changes' do
    it 'works' do
      p = Fichte::Parser.new File.read(File.join(File.dirname(__FILE__), "fixtures", "parsethis.html"))
      
      p.changes.last.altes_fach.should == "4Sp2"
      p.changes.last.detail.should == nil
      p.changes.last.klasse.should == "K2-4Sp2"
      p.changes.last.num.should == 217
    end
    
    it 'does not choke on empty klass field' do
      p = Fichte::Parser.new File.read(File.join(File.dirname(__FILE__), "fixtures", "empty_klasse.html"))
      p.changes.length.should == 0
    end
  end
end