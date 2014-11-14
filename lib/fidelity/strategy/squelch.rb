module Fidelity
  module Strategy
    class Squelch < Compress

      # these are the default values of sox's squelch example, see `man sox`
      def params
        ".1,.1 -45.1,-45,-inf,0,-inf 45 -90 .1"
      end

    end
  end
end
