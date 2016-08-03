class Venue < ActiveRecord::Base

  class << self
    def briefing
      not_offline.map(&:attributes)
    end
    def mapping
      Hash[all.pluck(:id, :slug)]
    end
  end

  STATES = %w( offline
               available
               provisioning
               device_required
               awaiting_stream
               connected
               disconnect_required
               disconnected )

  STATES.each do |state|
    scope state.to_sym, -> { where(state: state) }
  end

  scope :not_offline, -> { where.not(state: 'offline') }

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  validates :name, :user_id, presence: true

  # this is the place to add more flags
  FLAGS = %w( autostart
              autoend
              lineup
              no_email )

  belongs_to :user
  has_many :talks

  before_create :set_default_state

  def set_default_state
    self.state = 'offline'
  end

  def flags
    YAML.load(options).select { |k, v| v }.map { |k, v| k.to_s }
  end

  def flags=(values)
    values = values.select { |v| !v.blank? }
    other = FLAGS.reduce({}) { |r, f| r.merge f => false }
    values.each { |v| other[v] = true }
    self.options = YAML.dump(YAML.load(options).merge(other))
  end

  private

  def slug_candidates
    [ :name, [:id, :name] ]
  end

end
