require 'tmpdir'

module AudioFixtureHelper
  def audio_fixture(path, glob='*')
    Dir.mktmpdir do |temp|
      glob = "#{path}/#{glob}"
      files = Dir.glob(glob)
      raise "no files found for #{glob}" if files.empty?
      FileUtils.cp(files, temp)
      FileUtils.chdir(temp) do
        yield temp, Dir.glob("#{temp}/#{glob}")
      end
    end
  end
end

RSpec.configure do |config|
  config.include AudioFixtureHelper
end
