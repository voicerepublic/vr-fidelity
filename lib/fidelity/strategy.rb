glob = File.expand_path(File.join(%w(.. strategy *.rb)), __FILE__)
Dir.glob(glob).each { |file| require(file) }

module Fidelity
  module Strategy
  end
end
