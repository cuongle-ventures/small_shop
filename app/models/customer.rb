class Customer < ApplicationRecord
  has_secure_password
  include Paginate

  has_many :orders

  def display_name
    "#{first_name} #{last_name}"
  end
end
