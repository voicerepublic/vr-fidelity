module Fidelity
  module Strategy
    class Desilence < Base

      class << self
        def required_executables
          %w( sox mv )
        end
      end

      # http://digitalcardboard.com/blog/2009/08/25/the-sox-of-silence/
      #
      # cut silence at the beginning and end & reduce silence in
      # between to 2 seconds if longer
      def silence
        "silence -l 1 0.2 1% -1 2.0 1% reverse silence 1 0.2 1% reverse"
      end

      def input
        "#{name}.wav"
      end

      def run
        desilence_wav
        output
      end

      def output
        input
      end

      def tmpfile
        "#{name}-desilenced.wav"
      end

      def desilence_wav_cmd
        "sox #{input} #{tmpfile} #{silence}; mv #{tmpfile} #{output}"
      end

    end
  end
end
