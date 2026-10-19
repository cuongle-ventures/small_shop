class Customer < ApplicationRecord
  has_secure_password
  include Paginate

  has_many :orders
end
