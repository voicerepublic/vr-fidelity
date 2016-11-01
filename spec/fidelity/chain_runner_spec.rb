require 'spec_helper'

describe Fidelity::ChainRunner do
  # fix to not depend on precursor
  pending 'runs chains' do
    audio_fixture('spec/fixtures/complex', '*.{flv,yml}') do
      Fidelity::ChainRunner.new('metadata.yml').run
    end
  end
end
