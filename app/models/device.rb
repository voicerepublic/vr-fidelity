class Device < ActiveRecord::Base

  class << self
    def mapping
      Hash[all.pluck(:id, :identifier)]
    end
  end

  self.inheritance_column = false

  validates :pairing_code, uniqueness: true, allow_nil: true

  belongs_to :organization

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

  def backup_recordings
    bucket = Settings.storage.backup_recordings.split('@').first
    Storage.directories.get(bucket, prefix: identifier+'/').files.sort_by do |file|
      file.last_modified
    end.reverse
  end

end
