require 'spec_helper'

describe Fidelity::Config do

  it 'generates fake journals' do
    audio_fixture('spec/fixtures/normalize0', '*.flv') do |path|
      setting = Fidelity::Config.new(path)
      path = setting.send(:journal_path)
      assert { File.exist?(path) }
    end
  end

  it 'parses journals' do
    audio_fixture('spec/fixtures/normalize0', '*.flv') do |path|
      setting = Fidelity::Config.new(path)
      assert { setting.journal.is_a?(Hash) }
    end
  end

  # there is no notion of users anymore
  pending 'provides a list of participating users' do
    audio_fixture('spec/fixtures/complex', 't1-u*') do |path|
      Dir.chdir(path) do
        setting = Fidelity::Config.new(path)
        assert { setting.users == %w( 1 2 ) }
      end
    end
  end

  # it doesn't work like this anymore
  pending 'provides the timestamp of the first fragment' do
    audio_fixture('spec/fixtures/complex', 't1-u*') do |path|
      Dir.chdir(path) do
        setting = Fidelity::Config.new(path)
        assert { setting.file_start == 1393335342 }
      end
    end
  end

end
