$:.unshift File.dirname(__FILE__)

require 'fidelity/version'
require 'fidelity/exec'
require 'fidelity/strategy'
require 'fidelity/config'

module Fidelity
  # Your code goes here...
end

# make sure dependencies are installed
#
# TODO go through strategies and see if the required executables can be found
