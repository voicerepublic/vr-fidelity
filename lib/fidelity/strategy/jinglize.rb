require 'tempfile'

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
        [ input ]
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
        start = jingle_file(jingles.first)
        stop  = jingle_file(jingles.last)
        merge_with_jingles start.path, stop.path
        start.unlink
        stop.unlink
        outputs
      end

      def outputs
        [ input, backup ]
      end

      def jingle_file(file)
        raw = Tempfile.new(%w(raw_jingle .wav))
        fetch file, raw.path
        cooked = Tempfile.new(%w(cooked_jingle .wav))
        transcode raw.path, cooked.path
        raw.unlink
        cooked
      end

      def fetch_cmd(source, destination)
        if source.match(/^https?:/)
          "wget -q -O #{destination} '#{source}'"
        else
          "cp #{source} #{destination}"
        end
      end

      def transcode_cmd(source, destination)
        "sox #{source} -c #{@channels} #{destination} rate -L #{@sample_rate}"
      end

      def merge_with_jingles_cmd(start, stop)
        "sox -V1 #{start} #{backup} #{stop} #{input}"
      end

      def jingles
        [ opts[:jingle_in],
          opts[:jingle_out] ]
      end

    end
  end
end
