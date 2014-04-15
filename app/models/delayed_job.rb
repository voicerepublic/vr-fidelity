class Delayed::Job

  scope :failed, -> { where.not(failed_at: nil) }

  scope :audio, -> { where(queue: 'audio') }
  scope :trigger, -> { where(queue: 'trigger') }
  scope :mail, -> { where(queue: 'mail') }

end
