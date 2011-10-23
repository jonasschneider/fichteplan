require File.expand_path('spec_helper', File.dirname(__FILE__))
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
  
  describe '#kursstufe?' do
    it 'can be false' do
      c = Fichte::Change.new :klasse => "08c"
      c.kursstufe?.should == false
    end
    
    it 'can be true' do
      c = Fichte::Change.new :klasse => "K2"
      c.kursstufe?.should == true
    end
  end
  
  describe '#klasse' do
    it 'returns klasse for normal' do
      c = Fichte::Change.new :klasse => "08c"
      c.klasse.should == "08c"
    end
    
    it 'returns klasse-fach bei kursstufe' do
      c = Fichte::Change.new :klasse => "K2", :altes_fach => "4E2"
      c.klasse.should == "K2-4E2"
    end
    
    it 'normalizes (08c)' do
      c = Fichte::Change.new :klasse => "(08c)"
      c.klasse.should == "08c"
    end
  end
  
  describe 'entfallene Stunde' do
    it 'works' do
      c= Fichte::Change.new :num => 1, :stunde => 4, :altes_fach => 'E2', :neues_fach => nil, :raum => nil, :vertreter => nil, :klasse => '05c'
      c.type.should == :entfall
      c.text.should == "4. Stunde (Englisch) entfällt"
    end
  end
  
  describe 'vertretene Stunde' do
    it 'works' do
      c= Fichte::Change.new :num => 1, :stunde => 4, :altes_fach => 'E2', :neues_fach => 'E2', :raum => '106', :vertreter => 'WTH', :klasse => '05c'
      c.type.should == :vertretung
      c.text.should == "4. Stunde (Englisch) bei WTH in Raum 106"
    end
  end
  
  describe 'getauschte Stunde' do
    it 'works' do
      c= Fichte::Change.new :num => 1, :stunde => 4, :altes_fach => 'E2', :neues_fach => 'D', :raum => '106', :vertreter => 'WTH', :klasse => '05c'
      c.type.should == :tausch
      c.text.should == "4. Stunde (Englisch) getauscht mit Deutsch bei WTH in Raum 106"
    end
  end
  
  describe '#to_json' do
    it 'returns instance vars' do
      c = Fichte::Change.new :num => 1
      c.to_json.should == '{"num":1}'
    end
  end
  
  describe '#matches_filter?' do
    it 'returns false when no match' do
      c = Fichte::Change.new :klasse => "08c"
      c.matches_filter?(%w(09c)).should == false
    end
    
    it 'returns true on exact match' do
      c = Fichte::Change.new :klasse => "08c"
      c.matches_filter?(%w(08c)).should == true
    end
    
    it 'returns true on kurs match' do
      c = Fichte::Change.new :klasse => "K2", :altes_fach => "4Et2"
      c.matches_filter?(%w(K2)).should == true
      c.matches_filter?(%w(K2-4Et2)).should == true
    end
    
    it 'returns true on kurs match regardless of third character' do
      c = Fichte::Change.new :klasse => "K2", :altes_fach => "4Et2"
      c.matches_filter?(%w(K2-4Eth2)).should == true
    end
  end
end