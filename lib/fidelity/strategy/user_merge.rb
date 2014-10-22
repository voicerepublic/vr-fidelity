module Fidelity
  module Strategy
    class UserMerge < KluuuMerge

      def run
        users.each_with_index do |user, index|
          merge_wavs fragments(user), outputs[index]
        end
        outputs
      end

      def outputs
        users.map { |u| "t#{name}-u#{u}-#{file_start(u)}.wav" }
      end

    end
  end
end
