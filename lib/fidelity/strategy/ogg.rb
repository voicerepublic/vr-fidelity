# transcodes the resulting wav file to ogg
#
module Fidelity
  module Strategy
    class Ogg < Base

      class << self
        def required_executables
          %w( oggenc )
        end
      end

      def input
        "#{name}.wav"
      end

      def run
        convert_wav_to_ogg
        output
      end

      def convert_wav_to_ogg_cmd
        "oggenc -Q -o #{output} #{input}"
      end

      def output
        "#{name}.ogg"
      end

    end
  end
end
