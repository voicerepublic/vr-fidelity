module Fidelity
  module Strategy
    class Cleanup < Base

      # finds files with result naming scheme
      def inputs
        Dir.glob("*.wav")
      end

      def run
        fu.rm(inputs)
      end

      # existence checked as postcondition
      def outputs
        []
      end

    end
  end
end
