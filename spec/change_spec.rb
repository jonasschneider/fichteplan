require 'change'
describe 'Change' do
  describe 'entfallene Stunde' do
    it 'works' do
      c= Fichte::Change.new :num => 1, :stunde => 4, :altes_fach => 'E2', :neues_fach => '---', :raum => '---', :vertreter => '---', :klasse => '05c'
      c.type.should == :entfall
      c.text.should == "4. Stunde (E2) entfällt"
    end
    
    describe 'mit Text' do
      it 'works' do
        c= Fichte::Change.new :num => 3, :stunde => 6, :altes_fach => 'F', :neues_fach => '---', :raum => '---', :vertreter => '---', :detail => 'Fail'
        c.type.should == :entfall
        c.text.should == "6. Stunde (F) entfällt - Fail"
      end
    end
  end
  
  describe 'vertretene Stunde' do
    it 'works' do
      c= Fichte::Change.new :num => 1, :stunde => 4, :altes_fach => 'E2', :neues_fach => 'E2', :raum => '106', :vertreter => 'WTH', :klasse => '05c'
      c.type.should == :vertretung
      c.text.should == "4. Stunde (E2) vertreten durch WTH in Raum 106"
    end
  
    describe 'mit Text' do
      it 'works' do
        c= Fichte::Change.new :num => 1, :stunde => 4, :altes_fach => 'E2', :neues_fach => 'E2', :raum => '106', :vertreter => 'WTH', :klasse => '05c', :detail => 'nächste Woche'
        c.type.should == :vertretung
        c.text.should == "4. Stunde (E2) vertreten durch WTH in Raum 106 - nächste Woche"
      end
    end
  end
end