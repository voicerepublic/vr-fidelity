# transcodes the resulting wav file to m4a
#
module Fidelity
  module Strategy
    class M4a < Base

      class << self
        def required_executables
          %w( avconv )
        end
      end

      def input
        "#{name}.wav"
      end

      def run
        convert_wav_to_m4a
        output
      end

      def convert_wav_to_m4a_cmd
        "avconv -v quiet -y -i #{input} -b:a 64k -strict experimental #{output}"
      end

      def output
        "#{name}.m4a"
      end

    end
  end
end
