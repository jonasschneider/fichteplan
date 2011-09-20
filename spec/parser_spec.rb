require 'parser'

describe 'Parser' do
  describe '#rows' do
    it 'parses' do
      p = Fichte::Parser.new File.read(File.join(File.dirname(__FILE__), "fixtures", "parsethis.html"))
      p.rows[7].inspect.should == '["254", "5", "F2", "JÖR", "206", "statt Do. 2. Std", "M", "08c"]'
    end
  end
  
  describe '#row_to_params' do
    p = Fichte::Parser.new
    p.row_to_params(["254", "5", "F2", "JÖR", "206", "statt Do. 2. Std", "M", "08c"]).should == { :num => 254, :stunde => 5, :neues_fach => "F2", :vertretung => "JÖR", :raum => 206, :detail => "statt Do. 2. Std", :altes_fach => "M", :klasse => "08c"}
  end
end