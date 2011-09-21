$:.unshift '.'
$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'app'

run Sinatra::Application