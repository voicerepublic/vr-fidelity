# Merges the resulting wav with the start and stop jingle.
#
# Prior to this strategy use MoveClean.
#
module Fidelity
  module Strategy
    class Rp14 < Jinglize

      def jingles
        # FIXME: expecting rails env
        [ Rails.root.join('lib/audio/files/rp14_podcast_en.wav'),
          Rails.root.join('lib/audio/files/rp14_podcast_en.wav') ]
      end

    end
  end
end
