require 'term/ansicolor'

module Fidelity
  class ConsoleLogger

    include Term::ANSIColor

    def method_missing(method, arg)
      prefix, suffix = nil, [reset, "\n"]
      case method
      when :debug then prefix = '    '
      when :info  then prefix = ["\n", green, '--> ']
      when :warn  then prefix = [orange, 'warn:']
      when :error then prefix = red
      when :fatal then prefix = [red, bold]
      when :unknown
        # noop
      else
        raise "unknown severity level #{method}"
      end
      lines = [arg].flatten.map { |s| s.split("\n") }.flatten
      lines.each do |line|
        subfix = nil
        case line[0]
        when '>' then subfix = cyan
        when '<' then subfix = brown
        end
        print *([prefix, subfix, line, suffix].flatten)
      end
    end

  end
end
