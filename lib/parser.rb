require 'nokogiri'
require 'fichte'
require 'change'

class Fichte::Parser
  def initialize data = ''
    @data = data
    @doc = Nokogiri::HTML.parse(@data)
  end
  
  def rows
    @doc.css("tr:not(:first-child)").map do |row|
      row.css("td").map do |cell|
        txt = cell.text.gsub("\302\240", "")
        if txt.empty? || txt == '---'
          nil
        else
          txt
        end
      end
    end
  end
  
  def row_to_params row
    keys = %w(num stunde neues_fach vertreter raum detail altes_fach klasse).map{|v|v.to_sym}
    params = {}
    raise if row.length != keys.length
    row.each_with_index do |val, i|
      params[keys[i]] = val && val.match(/^\d+$/) ? val.to_i : val
    end
    params[:date] = date
    params
  end
  
  def split_forms changes
    changes.map do |change|
      if change[:klasse].match(", ")
        change[:klasse].split(", ").map{|k| x=change.dup; x[:klasse] = k; x}
      else
        change
      end
    end.flatten
  end
  
  def changes
    split_forms(rows.map{|r| row_to_params r }).map{|p| Fichte::Change.new p }
  end
  
  def date
    @doc.css(".mon_title").first.text.split(" ").first
  end
  
  def next_page_name
    if next_page_link = @doc.css("meta[http-equiv=\"refresh\"]").first
      next_page_link['content'].gsub('7; URL=', '')
    end
  end
      
end