require 'spec_helper'

describe TalkSetting do

  it 'generates fake journals' do
    audio_fixture('spec/support/fixtures/normalize0', '*.flv') do |path|
      setting = TalkSetting.new(path)
      path = setting.send(:journal_path)
      expect(File.exist?(path)).to be_true
    end
  end
  
  it 'parses journals' do
    audio_fixture('spec/support/fixtures/normalize0', '*.flv') do |path|
      setting = TalkSetting.new(path)
      expect(setting.journal).to be_a(Hash) 
    end
  end

  it 'provides a list of participating users' do
    audio_fixture('spec/support/fixtures/complex', 't1-u*') do |path|
      Dir.chdir(path) do
        setting = TalkSetting.new(path)
        expect(setting.users).to eq(%w( 1 2 ))
      end
    end
  end

  it 'provides the timestamp of the first fragment' do
    audio_fixture('spec/support/fixtures/complex', 't1-u*') do |path|
      Dir.chdir(path) do
        setting = TalkSetting.new(path)
        expect(setting.file_start).to eq(1393335342)
      end
    end
  end

end
