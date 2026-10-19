class Customer < ApplicationRecord
  has_secure_password
  include Paginate
end
