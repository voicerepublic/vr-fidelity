# noise gate wav file
#
module Fidelity
  module Strategy
    class NoiseGate < Compress

      def params
        # these are the default values of sox's noise-gate example, see `man sox`
        ".1,.2 -inf,-50.1,-inf,-50,-50 0 -90 .1"
      end

    end
  end
end
