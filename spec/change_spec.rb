require 'change'

describe 'Change' do
  describe '#stunde' do
    it 'prints a dot after each number' do
      c = Fichte::Change.new :stunde => 6
      c.stunde.should == "6."
      
      c = Fichte::Change.new :stunde => "6 - 7"
      c.stunde.should == "6. - 7."
    end
  end
  
  describe '#klasse' do
    it 'returns klasse for normal' do
      c = Fichte::Change.new :klasse => "08c"
      c.klasse.should == "08c"
    end
    
    it 'returns klasse for normal' do
      c = Fichte::Change.new :klasse => "K2", :altes_fach => "4E2"
      c.klasse.should == "K2-4E2"
    end
  end
  
  describe 'entfallene Stunde' do
    it 'works' do
      c= Fichte::Change.new :num => 1, :stunde => 4, :altes_fach => 'E2', :neues_fach => nil, :raum => nil, :vertreter => nil, :klasse => '05c'
      c.type.should == :entfall
      c.text.should == "4. Stunde (E2) entfällt"
    end
  end
  
  describe 'vertretene Stunde' do
    it 'works' do
      c= Fichte::Change.new :num => 1, :stunde => 4, :altes_fach => 'E2', :neues_fach => 'E2', :raum => '106', :vertreter => 'WTH', :klasse => '05c'
      c.type.should == :vertretung
      c.text.should == "4. Stunde (E2) vertreten durch WTH in Raum 106"
    end
  end
  
  describe 'getauschte Stunde' do
    it 'works' do
      c= Fichte::Change.new :num => 1, :stunde => 4, :altes_fach => 'E2', :neues_fach => 'D', :raum => '106', :vertreter => 'WTH', :klasse => '05c'
      c.type.should == :tausch
      c.text.should == "4. Stunde (E2) getauscht mit D bei WTH in Raum 106"
    end
  end
  
  describe '#to_json' do
    it 'returns instance vars' do
      c = Fichte::Change.new :num => 1
      c.to_json.should == '{"num":1}'
    end
  end
end