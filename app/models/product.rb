class Product < ApplicationRecord
  include Activable
  include Paginate
  has_many :order_items
  has_many :orders, through: :order_items
end
