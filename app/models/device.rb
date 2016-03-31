class Device < ActiveRecord::Base

  self.inheritance_column = false

  belongs_to :organization

end
