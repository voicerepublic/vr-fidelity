require 'spec_helper'

describe Fidelity::Strategy::KluuuMerge do

  it 'merges kluuu-style' do
    # we need the wav fragments and the flvs (to reconstruct the journal)
    audio_fixture('spec/fixtures/complex', 't1-u*') do |path|
      setting = Fidelity::Config.new(path)
      result = Fidelity::Strategy::KluuuMerge.call(setting)

      file = [path, result] * '/'
      assert { File.exist?(file) }
    end
  end

  # it 'merges streams synchronously' do
  #   fixture = 'spec/fixtures/complex'
  #   audio_fixture(fixture, 't1-u*.flv') do |path|
  #     s = Fidelity::Config.new(path)
  #     Fidelity::Strategy::Precursor.call(s)
  #     p1 = Fidelity::Strategy::KluuuMerge.call(s)
  #
  #     p0 = "#{fixture}/1.wav"
  #     #c0 = open(p0, "rb") {|io| io.read }
  #     #c1 = open(p1, "rb") {|io| io.read }
  #
  #     #%x[ aplay #{p0} ]
  #     #%x[ aplay #{path}/#{p1} ]
  #
  #     # expect(c1).to eq(c0)
  #   end
  # end

end
