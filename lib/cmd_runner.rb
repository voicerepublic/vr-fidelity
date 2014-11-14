require "open4"

# Example Usage
#
#     class A
#       include CmdRunner
#
#       def initialize
#         run_on_init
#       end
#
#       def run_on_init_cmd
#         'command_to_run'
#       end
#     end
#
# TODO: should go into trickery
module CmdRunner

  private

  def run_cmd(method, *args)
    cmds = send(method, *args)

    stdout_output = ''

    cmds.split("\n").each do |cmd|
      # log if a logger is present
      logger.debug("% #{cmd}") if respond_to?(:logger)

      pid, stdin, stdout, stderr = Open4::popen4(cmd)

      stdout_output += stdout.read

      if respond_to?(:logger)
        logger.debug(stdout_output)
        logger.warn(stderr.read)
      end
    end

    stdout_output
  end



  def method_missing(method, *args)
    cmd_method = "#{method}_cmd"
    return run_cmd(cmd_method, *args) if respond_to?(cmd_method)
    super
  end

end
