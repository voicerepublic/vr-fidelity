$:.unshift File.dirname(__FILE__)

require 'fidelity/version'
require 'fidelity/exec'
require 'fidelity/strategy'
require 'fidelity/config'
require 'fidelity/strategy_runner'
require 'fidelity/chain_runner'

module Fidelity
  LOG_FILENAME = 'fidelity.log'
end

# make sure dependencies are installed
constants = Fidelity::Strategy.constants.map { |c| Fidelity::Strategy.const_get(c) }
classes = constants.select { |c| c.is_a?(Class) }
executables = classes.map { |strategy| strategy.required_executables }.flatten.uniq
executables.each do |e|
  raise "Could not find executable '#{e}'" if %x[which #{e}].chomp.empty?
end
