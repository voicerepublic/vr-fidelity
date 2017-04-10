class Device < ActiveRecord::Base

  class << self
    def mapping
      Hash[all.pluck(:id, :identifier)]
    end
  end

  self.inheritance_column = false

  validates :pairing_code, uniqueness: true, allow_nil: true

  belongs_to :organization
  has_many :device_reports

  def unpair!
    self.pairing_code = ('0'..'9').to_a.shuffle[0,4].join
    self.state = 'pairing'
    self.name = nil
    self.paired_at = nil
    self.organization_id = nil
    save!
  rescue
    retry
  end

  def recordings
    (new_recordings + old_recordings).sort_by { |f| -f[:date].to_i }
  end

  private

  def prefix
    identifier+'/'
  end

  def files
    bucket = Settings.storage.backup_recordings.split('@').first
    Storage.directories.get(bucket, prefix: prefix).files
  end

  def old_recordings
    files.select { |f| f.key.match(/recording_\d+_\d+\.ogg$/) }.map do |file|
      {
        name: file.key.sub(prefix, ''),
        date: Time.at(file.key.match(/_(\d+)(_\d+)?\.ogg$/)[1].to_i),
        duration: hms(estimate_duration(file.content_length)),
	      size: file.content_length,
        link: "/backup/#{file.key}"
      }
    end
  end

  def new_recordings
    files.select { |f| f.key.match(/rec_\d+_\d+\.ogg$/) }.map do |file|
      key = file.key.sub(prefix, '')
      {
        name: key,
        date: DateTime.strptime(key, 'rec_%Y%m%d_%H%M%S.ogg').to_time,
        duration: hms(estimate_duration(file.content_length)),
        size: file.content_length,
        link: "/backup/#{file.key}"
      }
    end
  end

  def hms(total_seconds)
    Time.at(total_seconds).utc.strftime("%H:%M:%S")
  end

  def estimate_duration(size)
    # based on the observation 1 MB per 87 seconds
    (size / 1024.0 ** 2) * 87
  end

end
