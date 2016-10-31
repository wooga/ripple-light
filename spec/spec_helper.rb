require 'rubygems' # Use the gems path only for the spec suite
require 'ripple-light'

require 'rspec'
require 'byebug'

%w[
  bar
  customer
  email
  car
  tire
].each do |f|
  require "model/#{f}"
end
