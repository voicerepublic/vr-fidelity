class Device < ActiveRecord::Base

  self.inheritance_column = false

  validates :pairing_code, uniqueness: true, allow_nil: true

  belongs_to :organization

  def unpair!
    self.pairing_code = ('0'..'9').to_a.shuffle[0,4].join
    self.state = 'unpaired'
    self.paired_at = nil
    self.organization_id = nil
    save!
  rescue
    retry
  end

end
