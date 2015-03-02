class Transaction < ActiveRecord::Base

  # disable sti
  self.inheritance_column = false

  belongs_to :source, polymorphic: true

  serialize :details

  # set some defaults
  before_create do
    self.type = 'ManualTransaction'
    self.state = 'pending'
  end

  def process!
    raise 'never call this in backoffice'
  end

end
