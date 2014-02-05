class User < ActiveRecord::Base

  has_many :venues
  #has_many :talks, through: :venues

end
