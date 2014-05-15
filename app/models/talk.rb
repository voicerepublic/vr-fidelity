# http://stackoverflow.com/questions/2529990/activerecord-date-format
#
# Attributes:
# * id [integer, primary, not null] - primary key
# * audio_formats [text, default="--- []\n"] - TODO: document me
# * created_at [datetime] - creation time
# * description [text] - TODO: document me
# * duration [integer, default=30] - TODO: document me
# * ended_at [datetime] - TODO: document me
# * ends_at [datetime] - TODO: document me
# * featured_from [datetime] - TODO: document me
# * image_uid [string] - TODO: document me
# * play_count [integer, default=0] - TODO: document me
# * processed_at [datetime] - TODO: document me
# * record [boolean, default=true] - TODO: document me
# * recording [string] - TODO: document me
# * session [text] - TODO: document me
# * started_at [datetime] - TODO: document me
# * starts_at [datetime] - TODO: document me
# * state [string] - TODO: document me
# * teaser [string] - TODO: document me
# * title [string]
# * updated_at [datetime] - last update time
# * venue_id [integer] - belongs to :venue
class Talk < ActiveRecord::Base

  STATES = %w( prelive live postlive processing archived )

  # TODO create a better more specific pattern for urls
  URL_PATTERN = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)/
  URL_MESSAGE = "if changed, must be a valid URL, i.e. matching #{URL_PATTERN}"

  belongs_to :venue, :inverse_of => :talks

  validates :venue, :title, :starts_at, :ends_at, presence: true

  validates :recording_override, format: { with: URL_PATTERN, message: URL_MESSAGE },
            if: ->(t) { t.recording_override? && t.recording_override_changed? }

  validate :related_talk_id_is_talk?, :on => :update

  before_validation :set_ends_at

  after_save :schedule_processing_override,
             if: ->(t) { t.recording_override? && t.recording_override_changed? }

  delegate :user, to: :venue

  image_accessor :image

  # poor man's auto scopes
  STATES.each do |state|
    scope state.to_sym, -> { where(state: state) }
  end

  scope :featured, -> { where.not(featured_from: nil) }

  def effective_duration # in seconds
    ended_at - started_at
  end

  def disk_usage # in bytes
    all_files.inject(0) do |result, file|
      result + File.size(file)
    end
  end

  def all_files
    path0 = File.expand_path(Settings.rtmp.archive_raw_path, Rails.root)
    rec0  = File.dirname(recording)
    glob0 = File.join(path0, rec0, "t#{id}-u*.flv")

    path1 = File.expand_path(Settings.rtmp.archive_path, Rails.root)
    glob1 = File.join(path1, "#{recording}*.*")

    path2 = File.expand_path(Settings.rtmp.recordings_path, Rails.root)
    glob2 = File.join(path2, "t#{id}-u*.flv")

    Dir.glob(glob0) + Dir.glob(glob1) + Dir.glob(glob2)
  end

  private

  def set_ends_at
    return unless starts_at
    self.ends_at = starts_at + duration.minutes
  end

  def schedule_processing_override
    Delayed::Job.enqueue ProcessOverride.new(id), queue: 'audio'
  end

  def related_talk_id_is_talk?
    return if related_talk_id.blank?
    begin
      Talk.find(related_talk_id)
    rescue
      errors.add(:related_talk_id, "is not a proper talk id")
    end
  end
end
