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
    cmd = send(method, *args)
    logfile.info cmd unless logfile.nil?
    %x[#{cmd}]
  end

  def method_missing(method, *args)
    cmd_method = "#{method}_cmd"
    return run_cmd(cmd_method, *args) if respond_to?(cmd_method)
    super
  end

end
