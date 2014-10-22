module Fidelity
  module Strategy
    class TalkMerge < KluuuMerge

      def inputs
        users.map { |u| "t#{name}-u#{u}-#{file_start(u)}.wav" }
      end

      def run
        frags = inputs.map do |i|
          [ i.sub('.wav', ''),
            i.match(/-(\d+)\./).to_a[1] ]
        end
        merge_wavs frags, output
        output
      end

    end
  end
end
