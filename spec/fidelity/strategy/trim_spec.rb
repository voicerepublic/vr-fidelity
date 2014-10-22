require 'spec_helper'

describe Fidelity::Strategy::Trim do

  it 'trims' do
    # we need the wav and the journal
    audio_fixture('spec/fixtures/complex', '*') do |path|
      setting = Fidelity::Config.new(path)
      file_start = setting.journal['record_done'].first.last.to_i
      setting.opts = {
        file_start: file_start,
        talk_start: file_start + 3, # 3s later
        talk_stop:  file_start + 6 # 6s later
      }
      result = Fidelity::Strategy::Trim.call(setting)

      file = [path, result] * '/'
      assert { File.exist?(file) }
      cmd = "soxi -D #{file}"
      duration = %x[ #{cmd} ].to_f.round
      assert { duration == 3 }
    end
  end

end
