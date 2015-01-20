# Merges the resulting wav with the start and stop jingle.
#
# The jingle files have to have a sample rate of 44.1k and 2 channels!
#
# Prior to this strategy use MoveClean.
#
module Fidelity
  module Strategy
    class Jinglize < Base

      class << self
        def required_executables
          %w( sox soxi mv )
        end
      end

      def input
        "#{name}.wav"
      end

      # checked as a precondition
      def inputs
        [ input ] + jingles
      end

      def backup
        "#{name}-bak.wav"
      end

      def identify_cmd(file)
        "soxi #{file}"
      end

      def classify(file)
        stdout = identify(file)
        @channels = stdout.match(/^Channels\s*: (.*)$/)[1]
        @sample_rate = stdout.match(/^Sample Rate\s*: (.*)$/)[1]
      end

      def run
        classify input
        fu.mv input, backup
        prep_jingle jingles.first
        prep_jingle jingles.last
        merge_with_jingles
        outputs
      end

      def outputs
        [ input, backup ]
      end

      def merge_with_jingles_cmd
        start = "prep-#{File.basename(jingles.first)}"
        stop  = "prep-#{File.basename(jingles.last)}"
        "sox -V1 #{start} #{backup} #{stop} #{input}"
      end

      def prep_jingle_cmd(file)
        base = File.basename(file)
        "sox #{file} -c #{@channels} prep-#{base} rate -L #{@sample_rate}"
      end

      def jingles
        [ opts[:jingle_in],
          opts[:jingle_out] ]
      end

    end
  end
end
