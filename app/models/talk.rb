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

  extend ::CsvImport
  
  GRADES = {
    ok:           "Everything ok. Quality acceptable. (ok)",
    override:     "Manually overriden, quailty is good. (override)",
    insufficient: "Insufficient or empty recording. (insufficient)",
    norecording:  "No recording, no override available. (no recording)",
    failed:       "Recording available, but processing failed. (failed)"
  }

  STATES = %w( prelive live postlive processing archived )

  # TODO create a better more specific pattern for urls
  URL_PATTERN = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)/
  URL_MESSAGE = "if changed, must be a valid URL, i.e. matching #{URL_PATTERN}"

  belongs_to :venue, :inverse_of => :talks

  acts_as_taggable
  validates :venue, :title, :starts_at, :ends_at, :tag_list, :uri, presence: true
  validates :uri, uniqueness: true
  
  validates :recording_override, format: { with: URL_PATTERN, message: URL_MESSAGE },
            if: ->(t) { t.recording_override? && t.recording_override_changed? }

  validate :related_talk_id_is_talk?, :on => :update

  before_validation :set_starts_at
  before_validation :set_ends_at
  before_save :nilify_grade
  
  validates :starts_at_date, format: { with: /\A\d{4}-\d\d-\d\d\z/,
                                       message: "Invalid time" }
  validates :starts_at_time, format: { with: /\A\d\d:\d\d\z/,
                                       message: "Invalid time" }
  
  after_save :schedule_processing_override,
             if: ->(t) { t.recording_override? && t.recording_override_changed? }

  delegate :user, to: :venue

  serialize :storage

  image_accessor :image

  # poor man's auto scopes
  STATES.each do |state|
    scope state.to_sym, -> { where(state: state) }
  end

  GRADES.keys.each do |grade|
    scope grade.to_sym, -> { where(grade: grade) }
  end

  scope :nograde, -> { where(grade: nil) }
  scope :featured, -> { where.not(featured_from: nil) }

  def effective_duration # in seconds
    ended_at - started_at
  end

  def disk_usage # in bytes
    storage.values.inject(0) { |result, file| result + file[:size] }
  end

  def flv_data
    # return @flv_data unless @flv_data.nil?
    # sum_size, sum_duration = 0, 0
    # all_files.each do |file|
    #   path, size, dur, start = file
    #   if path =~ /\.flv$/
    #     sum_size += size if size
    #     if dur
    #       h, m, s = dur.split(':').map(&:to_i)
    #       sum_duration += (h * 60 + m) * 60 + s
    #     end
    #   end
    # end
    # h = sum_duration / 3600
    # m = sum_duration % 3600 / 60
    # s = sum_duration % 60
    # @flv_data = [sum_size, '%02d:%02d:%02d' % [h, m, s]]
  end

  private

  # Assemble `starts_at` from `starts_at_date` and `starts_at_time`.
  #
  # Since the validity of `starts_at_date` and `starts_at_time` is ensured
  # with regexes we are allowed to be optimistic about parsing here.
  def set_starts_at
    self.starts_at = Time.zone.parse([starts_at_date, starts_at_time] * ' ')
  end

  def set_ends_at
    return unless starts_at
    self.ends_at = starts_at + duration.minutes
  end

  def schedule_processing_override
    Delayed::Job.enqueue ProcessOverride.new(id: id), queue: 'audio'
  end

  def related_talk_id_is_talk?
    return if related_talk_id.blank?
    begin
      Talk.find(related_talk_id)
    rescue
      errors.add(:related_talk_id, "is not a proper talk id")
    end
  end

  def nilify_grade
    self.grade = nil if grade.blank?
  end
  
end
