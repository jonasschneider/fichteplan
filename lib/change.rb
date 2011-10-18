require 'fichte'
require 'json'

class Fichte::Change
  attr_accessor :num, :stunde, :altes_fach, :neues_fach, :vertreter, :raum, :klasse, :detail, :date
  
  def initialize params
    params.each do |k, v|
      send "#{k}=", v
    end
  end
  
  def to_json *a
    dataz = {}
    instance_variables.each do |ivar|
      dataz[ivar.to_s.slice(1, 100)] = instance_variable_get ivar
    end
    dataz.to_json(*a)
  end
  
  def stunde
    if @stunde.kind_of? String
      @stunde.gsub(/(\d+)/){ |n| "#{n}." }
    else
      @stunde.to_s.gsub(/(\d+)/){ |n| "#{n}." }
    end
  end
  
  def kursstufe?
    @klasse.match(/^K\d+$/) != nil
  end
  
  def base_klasse
    @klasse
  end
  
  def klasse
    if kursstufe?
      "#{@klasse}-#{@altes_fach}"
    else
      @klasse.gsub /[\(\)]/, ''
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
    "#{stunde} Stunde #{!kursstufe? ? "(#{altes_fach}) " : ""}#{action}#{detail && " - #{detail}"}"
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
  
  def matches_filter? filter
    regex = /(K\d-\d+.+)(\d+)/
    choices = [klasse, base_klasse, Regexp.new(klasse.gsub(regex){ $1 + '.' + $2 })]

    choices.any? do |choice|
      if choice.kind_of? Regexp
        filter.any? { |txt| choice.match(txt) }
      else
        filter.include? choice
      end
    end
  end
end
