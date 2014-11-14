module Fidelity
  module Strategy
    class NormalizeUsers < NormalizeFragments

      def inputs
        users.map { |u| "t#{name}-u#{u}-#{file_start(u)}.wav" }
      end

    end
  end
end
