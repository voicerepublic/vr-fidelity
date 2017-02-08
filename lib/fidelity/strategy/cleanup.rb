module Fidelity
  module Strategy
    class Cleanup < Base

      # TODO this would all be much easier if we'd move all to its own
      # directory beforehand
      def inputs
        Dir.glob("*.wav")
      end

      def run
        fu.rm(inputs)
      end

    end
  end
end
