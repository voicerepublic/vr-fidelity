module Fidelity
  module Strategy
    class Cleanup < Base

      # TODO this would all be much easier if we'd move all to its own
      # directory beforehand
      def inputs
        ["#{name}.wav"] +
          Dir.glob("#{name}-*.wav") + # covers -clean, -precut, -bak, -untrimmed
          fragments.map { |f| f.first.sub('.flv', '.wav') }
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
