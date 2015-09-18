# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime, not null] - creation time
# * description [text] - TODO: document me
# * duration [integer] - TODO: document me
# * featured_from [datetime] - TODO: document me
# * image_content_type [string] - TODO: document me
# * image_file_name [string] - TODO: document me
# * image_file_size [integer] - TODO: document me
# * image_uid [string] - TODO: document me
# * image_updated_at [datetime] - TODO: document me
# * options [text, default="--- {}\n"] - TODO: document me
# * start_time [datetime] - TODO: document me
# * teaser [text] - TODO: document me
# * title [string]
# * updated_at [datetime, not null] - last update time
# * user_id [integer] - belongs to :user
class Series < ActiveRecord::Base

  # this is the place to add more flags
  FLAGS = %w( no_auto_end_talk
              autostart ).sort

  belongs_to :user
  has_many :talks

  image_accessor :image

  def flags
    YAML.load(options).select { |k, v| v }.map { |k, v| k.to_s }
  end

  def flags=(values)
    values = values.select { |v| !v.blank? }
    other = FLAGS.reduce({}) { |r, f| r.merge f => false }
    values.each { |v| other[v] = true }
    self.options = YAML.dump(YAML.load(options).merge(other))
  end

end
