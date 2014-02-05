class User < ActiveRecord::Base

  has_many :venues
  #has_many :talks, through: :venues

  def full_name
    [firstname, lastname].compact * ' '
  end

end
