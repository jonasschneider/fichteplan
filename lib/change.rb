module Fichte
end

class Fichte::Change
  attr_reader :num, :stunde, :altes_fach
  
  def initialize params
    params.each do |k, v|
      instance_variable_set "@#{k}", v
    end
  end
  
  class AssertionFailed < Exception; end
  
  def assert(condition)
    raise AssertionFailed unless condition
  end
  
  def text
    "#{stunde}. Stunde (#{altes_fach}) entfällt"
  end
  
  def type
    return :entfall
    case type_text
    when "Entfall"
      assert new_room == '---'
      assert new_subject == '---'
      assert new_teacher == '---'
      :entfall
    when "Raum-Vtr."
      assert new_room != old_room
      assert new_subject == old_subject
      assert new_teacher == old_teacher
      :raum
    when "Vertretung"
      assert new_teacher != old_teacher
      :vertretung
    when "Betreuung"
      :betreuung
    when "Verlegung"
      assert !moved_from.empty? || !moved_to.empty?
      :verlegung
    when "Tausch"
      :tausch
    else
      :dunno
    end
  rescue AssertionFailed
    :dunno
  end
end
