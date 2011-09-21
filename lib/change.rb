require 'fichte'
require 'json'

class Fichte::Change
  attr_accessor :num, :stunde, :altes_fach, :neues_fach, :vertreter, :raum, :klasse, :detail
  
  def initialize params
    params.each do |k, v|
      send "#{k}=", v
    end
  end
  
  def to_json
    dataz = {}
    instance_variables.each do |ivar|
      dataz[ivar.to_s.slice(1, 100)] = instance_variable_get ivar
    end
    dataz.to_json
  end
  
  def stunde
    if @stunde.kind_of? String
      @stunde.gsub(/(\d+)/){ |n| "#{n}." }
    else
      @stunde.to_s.gsub(/(\d+)/){ |n| "#{n}." }
    end
  end
  
  def klasse
    if @klasse.match /^K\d+$/
      "#{@klasse}-#{@altes_fach}"
    else
      @klasse
    end
  end
  
  def text
    action = case type
      when :entfall
        "entfällt"
      when :vertretung
         "vertreten durch #{vertreter} in Raum #{raum}"
      when :tausch
         "getauscht mit #{neues_fach} bei #{vertreter} in Raum #{raum}"
      end
    "#{stunde} Stunde (#{altes_fach}) #{action}#{detail && " - #{detail}"}"
  end
  
  def type
    if raum == nil && neues_fach == nil && vertreter == nil
      :entfall
    elsif raum != nil && neues_fach != nil && vertreter != nil && neues_fach != altes_fach
      :tausch
    elsif raum != nil && neues_fach != nil && vertreter != nil
      :vertretung
    else
      :fail
    end
  end
end
