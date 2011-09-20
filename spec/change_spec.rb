require 'change'
describe 'Change' do
  describe 'entfallene Stunde' do
    it 'works' do
      c= Fichte::Change.new :num => 1, :stunde => 4, :altes_fach => 'E2', :neues_fach => '---', :raum => '---', :vertreter => '---', :klasse => '05c'
      c.type.should == :entfall
      c.text.should == "4. Stunde (E2) entfällt"
      
      c= Fichte::Change.new :num => 3, :stunde => 6, :altes_fach => 'F', :neues_fach => '---', :raum => '---', :vertreter => '---'
      c.type.should == :entfall
      c.text.should == "6. Stunde (F) entfällt"
    end
  end
end