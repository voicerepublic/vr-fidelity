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
# * series_id [integer] - belongs to :series
class Talk < ActiveRecord::Base

  class << self
    def briefing
      within(4.hours.ago, 6.hours.from_now).map(&:attributes)
    end
  end

  include ApplicationHelper

  extend ::CsvImport

  STATES = %w( pending prelive live postlive processing archived suspended )

  # TODO create a better more specific pattern for urls
  URL_PATTERN = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)/
  URL_MESSAGE = "if changed, must be a valid URL, i.e. matching #{URL_PATTERN}"

  attr_accessor :venue_name

  belongs_to :series, inverse_of: :talks
  belongs_to :venue

  acts_as_taggable

  before_validation :set_starts_at_time_and_date
  before_validation :set_ends_at
  before_save :set_description_as_html, if: :description_changed?

  validates :title, :starts_at, :ends_at, :tag_list, :uri, presence: true
  validates :uri, uniqueness: true

  # The whole "choose your own uri", will bite us, if we're not extra
  # carefull. I've repeatedly observed that operations used not
  # wellformed uris, despite the fact that it is clearly documented on
  # the import page. Thus, it will eventually happen, that a not
  # wellformed prefix of an annual conference is used in subsequent
  # year, effectivly overwriting existing talks. We will lose data &
  # slugs will be all messed up. This is my attempt to be careful. (It
  # only applies on create, so it shouldn't affect existing uris.)
  validates :uri, on: :create, format: { with: /\A[a-zA-Z]+\d+-[a-zA-Z\d]+\z/,
                                         message: "not wellformed." }

  validates :title, length: { maximum: Settings.limit.string }
  validates :teaser, length: { maximum: Settings.limit.string }
  validates :description, length: { maximum: Settings.limit.text }

  validates :recording_override, if: :process_override?,
            format: { with: URL_PATTERN, message: URL_MESSAGE }
  validates :slides_uuid, if: :process_slides?,
            format: { with: URL_PATTERN, message: URL_MESSAGE }

  validates :starts_at_date, format: { with: /\A\d{4}-\d\d-\d\d\z/,
                                       message: "Invalid time" }
  validates :starts_at_time, format: { with: /\A\d\d:\d\d\z/,
                                       message: "Invalid time" }
  validate :related_talk_id_is_talk?, on: :update

  before_save :set_venue
  before_save :set_icon, if: :tag_list_changed?
  after_save :generate_flyer!, if: :generate_flyer?
  after_save :schedule_processing_override, if: :process_override?
  after_save :schedule_processing_slides, if: :process_slides?
  after_save :schedule_forward, if: :schedule_forward?

  validate :series_id do
    begin
      Series.find(series_id)
    rescue
      errors[:series_id] = "with id #{series_id} not found"
    end
  end

  delegate :user, to: :series

  serialize :storage
  serialize :listeners
  serialize :social_links

  image_accessor :image

  # poor man's auto scopes
  STATES.each do |state|
    scope state.to_sym, -> { where(state: state) }
  end

  scope :featured, -> { where.not(featured_from: nil) }

  scope :within, ->(from, to) do
    where('ends_at > ? AND starts_at < ?', from, to)
  end

  scope :uncategorized, -> { where(icon: 'default') }

  scope :prelive_or_live, -> { where('talks.state in (?)', [:prelive, :live]) }
  scope :ordered, -> { order('starts_at ASC') }

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

  # TODO provide a list of expected streams (host + guests)
  def streams
    []
  end

  def listeners_for_json
    count = 0
    listeners.values.sort.map do |time|
      { time: time, count: count += 1 }
    end
  end

  # a transformer for use in csv import
  #
  # converts given field from html 2 markdown if a html tag is
  # detected
  def html2md(field)
    return if !self[field].match(/<[a-z][\s\S]*>/)
    self[field] = ReverseMarkdown.convert(self[field])
  end

  def self_url
    public_url(self, Settings.site_root)
  end

  private

  def set_icon
    bundles = TagBundle.category.tagged_with(tag_list, any: true)
    unless bundles.empty?
      icons = bundles.map { |b| [b.icon, (b.tag_list & tag_list).size] }
      icon = icons.sort_by(&:last).last.first
    end
    self.icon = icon || 'default'
  end

  def set_venue
    self.venue_name = venue_name.to_s.strip
    return if venue_name.blank? and venue.present?
    self.venue_name = 'Default venue' if venue_name.blank?
    self.venue = user.venues.find_or_create_by(name: venue_name)
  end

  # Assemble `starts_at` from `starts_at_date` and `starts_at_time`.
  #
  # Since the validity of `starts_at_date` and `starts_at_time` is ensured
  # with regexes we are allowed to be optimistic about parsing here.
  def set_starts_at_time_and_date
    self.starts_at_time = starts_at.strftime("%H:%M")
    self.starts_at_date = starts_at.strftime("%Y-%m-%d")
  end

  def set_ends_at
    return unless starts_at
    self.ends_at = starts_at + duration.minutes
  end

  def process_override?
    recording_override? and recording_override_changed?
  end

  def schedule_processing_override
    Delayed::Job.enqueue ProcessOverride.new(id: id), queue: 'audio'
  end

  def process_slides?
    slides_uuid? and slides_uuid_changed?
  end

  def schedule_processing_slides
    Delayed::Job.enqueue ProcessSlides.new(id: id), queue: 'audio'
  end

  def schedule_forward?
    forward_url_changed? and forward_url.present?
  end

  def schedule_forward
    Delayed::Job.enqueue Forward.new(id: id), queue: 'trigger'
  end

  def related_talk_id_is_talk?
    return if related_talk_id.blank?
    begin
      Talk.find(related_talk_id)
    rescue
      errors.add(:related_talk_id, "is not a proper talk id")
    end
  end

  def generate_flyer?
    starts_at_changed? or title_changed?
  end

  def generate_flyer!
    Delayed::Job.enqueue GenerateFlyer.new(id: id), queue: 'audio'
  end

  def set_description_as_html
    self.description_as_html = MARKDOWN.render(description)
  end

end
