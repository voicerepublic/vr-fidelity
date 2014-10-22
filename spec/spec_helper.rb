require 'bundler/setup'
Bundler.setup

require File.expand_path(File.join(%w(.. .. lib fidelity)), __FILE__)
require 'wrong/adapters/rspec'

require File.expand_path(File.join(%w(.. support audio_fixture)), __FILE__)

RSpec.configure do |config|
  # some (optional) config here
end
