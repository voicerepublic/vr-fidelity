# Attributes:
# * id [integer, primary, not null] - primary key
# * about [text] - TODO: document me
# * available [string] - TODO: document me
# * avatar_uid [string] - TODO: document me
# * created_at [datetime, not null] - creation time
# * current_sign_in_at [datetime] - TODO: document me
# * current_sign_in_ip [string] - TODO: document me
# * email [string, default="", not null]
# * encrypted_password [string, default="", not null] - TODO: document me
# * firstname [string] - TODO: document me
# * guest [boolean] - TODO: document me
# * header_uid [string] - TODO: document me
# * image_content_type [string] - TODO: document me
# * image_file_name [string] - TODO: document me
# * image_file_size [integer] - TODO: document me
# * image_updated_at [datetime] - TODO: document me
# * last_request_at [datetime] - TODO: document me
# * last_sign_in_at [datetime] - TODO: document me
# * last_sign_in_ip [string] - TODO: document me
# * lastname [string] - TODO: document me
# * provider [string] - TODO: document me
# * remember_created_at [datetime] - TODO: document me
# * reset_password_sent_at [datetime] - TODO: document me
# * reset_password_token [string] - TODO: document me
# * sign_in_count [integer, default=0] - TODO: document me
# * slug [text] - TODO: document me
# * timezone [string] - TODO: document me
# * uid [string] - TODO: document me
# * updated_at [datetime, not null] - last update time
# * website [string] - TODO: document me
class User < ActiveRecord::Base

  has_many :venues
  has_many :purchases, foreign_key: :owner_id

  scope :nonguests, -> { where(guest: nil) }
  scope :paying, -> { where('purchases_count > 0') }

  image_accessor :avatar

  def full_name
    [firstname, lastname].compact * ' '
  end

end
