class Venue < ActiveRecord::Base

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  validates :name, :user_id, presence: true

  # this is the place to add more flags
  FLAGS = %w( autostart
              autoend
              lineup )

  belongs_to :user
  has_many :talks

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
