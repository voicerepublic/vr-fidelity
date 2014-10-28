require 'term/ansicolor'

module Fidelity
  class ConsoleLogger

    METHODS = %w( debug info warn error fatal unknown )

    include Term::ANSIColor

    def method_missing(method, *args)
      return super unless METHODS.include?(method.to_s)
      arg = args.shift
      prefix, suffix = nil, [reset, "\n"]
      case method
      when :debug then prefix = '    '
      when :info  then prefix = ["\n", green, '--> ']
      when :warn  then prefix = ['    ', red]
      when :error then prefix = [red, bold]
      when :fatal then prefix = [black, on_red]
      when :unknown
        # noop
      else
        raise "unknown severity level #{method}"
      end
      arg.split("\n").each do |line|
        subfix = nil
        case line[0]
        when '%' then subfix = cyan
        end
        parts = [prefix, subfix, line, suffix].flatten
        print *parts
      end
    end

  end
end
