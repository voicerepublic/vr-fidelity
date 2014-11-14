module Fidelity
  module Strategy
    class Normalize < NormalizeFragments

      def inputs
        ["#{name}.wav"]
      end

    end
  end
end
