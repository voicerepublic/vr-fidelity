class Metric < ActiveRecord::Base

  scope :ordered, -> { order('created_at ASC') }

  scope :by_key, ->(key) { where(key: key).ordered.pluck(:value) }
  scope :times, -> { where(key: 'metrics_figures_total').ordered.pluck(:created_at).map { |t| t.strftime('%Y-%m-%d') } }

end
