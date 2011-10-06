require "bundler/setup"
Bundler.require :default


$:.unshift File.join(File.dirname(__FILE__), "lib")
require 'change'
require 'parser'
require 'fetcher'

$cache = Dalli::Client.new

def fetch_changes!
  begin
    c = Fichte::Fetcher.run!
  rescue Timeout::Error
    puts "t/o"
  else
    $cache.set 'changes', Marshal.dump(c)
    $cache.set 'changes_lastupdate', Time.new.to_i
  end
end


loop do
  begin
    puts "fetching"
    fetch_changes!
    puts "done"
    
  rescue Exception => e
    puts e.inspect
  end
  
  sleep 60
end