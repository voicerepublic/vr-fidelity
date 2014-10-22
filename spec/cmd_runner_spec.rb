require 'spec_helper'

describe CmdRunner do
  it 'runs commands' do
    assert do
      Class.new do
        include CmdRunner
        def my_test_cmd
          'echo hello'
        end
      end.new.my_test == "hello\n"
    end
  end

  it 'runs commands with params' do
    assert do
      Class.new do
        include CmdRunner
        def my_test_cmd(arg)
          "echo hello #{arg}"
        end
      end.new.my_test('world') == "hello world\n"
    end
  end
end
