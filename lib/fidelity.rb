$:.unshift File.dirname(__FILE__)

require 'fidelity/version'
require 'fidelity/exec'
require 'fidelity/strategy'
require 'fidelity/config'

module Fidelity
  # Your code goes here...
end

# make sure dependencies are installed
constants = Fidelity::Strategy.constants.map { |c| Fidelity::Strategy.const_get(c) }
classes = constants.select { |c| c.is_a?(Class) }
executables = classes.map { |strategy| strategy.required_executables }.flatten.uniq
executables.each do |e|
  if %x[which #{e}].chomp.empty?
    warn "could not find executable '#{e}'"
    exit
  end
end
