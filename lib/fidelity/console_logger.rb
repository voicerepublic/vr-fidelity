require 'term/ansicolor'

module Fidelity
  class ConsoleLogger

    METHODS = %w( debug info warn error fatal unknown )

    include Term::ANSIColor

    def method_missing(method, *args)
      return super unless METHODS.include?(method.to_s)

      arg = args.shift
      arg.split("\n").each do |line|
        print *[ prefix[method],
                 subfix[line[0]],
                 line,
                 suffix ].flatten
      end
    end

    def prefix
      @prefix ||= {
        debug:   '    ',
        info:    [ "\n", green, '--> ' ],
        warn:    [ '    ', red ],
        error:   [ red, bold ],
        fatal:   [ black, on_red ],
        unknown: nil
      }
    end

    # adjust formatting based on first char of line
    def subfix
      @subfix ||= {
        '%' => cyan
      }
    end

    def suffix
      @suffix ||= [ reset, "\n" ]
    end

  end
end
