class Metric < ActiveRecord::Base

  scope :latest, -> { order('created_at DESC').select(:key).distinct }

end
