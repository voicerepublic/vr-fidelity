# compress wav file
#
module Fidelity
  module Strategy
    class Compress < Base

      class << self
        def required_executables
          %w( sox mv )
        end
      end

      def input
        "#{name}.wav"
      end

      def run
        compress_wav input
        output
      end

      def output
        input
      end

      def tmpfile
        "#{name}-compressed.wav"
      end

      # these are the default values of audacity's compressor
      #
      #   Attack Time:  0.2 secs  (attack1)
      #   Decay Time:   1.0 secs  (decay1)
      #   Noice Floor:  -40 dB    (in-dB1)
      #
      def params
        ".2,1 -40"
      end

      def compress_wav_cmd(file)
        "sox #{file} #{tmpfile} compand #{params}; mv #{tmpfile} #{file}"
      end

    end
  end
end
