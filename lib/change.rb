require 'fichte'

class Fichte::Change
  attr_accessor :num, :stunde, :altes_fach, :neues_fach, :vertreter, :raum, :klasse, :detail
  
  def initialize params
    params.each do |k, v|
      send "#{k}=", v
    end
  end
  
  
  def text
    action = case type
      when :entfall
        "entfällt"
      when :vertretung
         "vertreten durch #{vertreter} in Raum #{raum}"
      end
    "#{stunde}. Stunde (#{altes_fach}) #{action}#{detail && " - #{detail}"}"
  end
  
  def type
    if raum == '---' && neues_fach == '---' && vertreter == '---'
      return :entfall
    elsif raum != '---' && neues_fach != '---' && vertreter != '---'
      return :vertretung
    else
      return :fail
    end
  end
end
