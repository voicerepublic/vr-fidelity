module Fidelity
  class Exec < Struct.new(:args)

    class << self
      def run(*args)
        new(args).run
      end
    end

    def run
      # TODO
    end

  end
end
