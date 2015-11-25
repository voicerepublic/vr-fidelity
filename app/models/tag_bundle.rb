class TagBundle < ActiveRecord::Base

  GROUPS = %w( category publisher format profession )

  GROUPS.each do |group|
    scope group.to_sym, -> { where(group: group) }
  end

  scope :standalone, -> { where(group: nil) }

  acts_as_taggable

end
