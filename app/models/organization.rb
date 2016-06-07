class Organization < ActiveRecord::Base

  has_many :devices

  scope :ordered, -> { order(:name) }

end
