# Merges the resulting wav with the start and stop jingle.
#
# The jingle files have to have a sample rate of 44.1k and 2 channels!
#
# Prior to this strategy use MoveClean.
#
module Fidelity
  module Strategy
    class Jinglize < Base

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

      def run
        FileUtils.mv(input, backup)
        unify backup
        merge_with_jingles
        outputs
      end

      def outputs
        [ input, backup ]
      end

      def tmpfile
        "#{name}-unified.wav"
      end

      def unify_cmd(file)
        "sox #{file} -c 2 #{tmpfile} rate -L 44.1k; mv #{tmpfile} #{file}"
      end

      def merge_with_jingles_cmd
        start, stop = jingles
        "sox -V1 #{start} #{backup} #{stop} #{input}"
      end

      def jingles
        # FIXME: expecting rails env
        [ Rails.root.join('lib/audio/files/vr_start.wav'),
          Rails.root.join('lib/audio/files/vr_stop.wav') ]
      end

    end
  end
end
