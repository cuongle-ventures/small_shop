class Order < ApplicationRecord
  include Paginate

  default_scope -> { where(customer_id: Current.customer.id) }

  belongs_to :customer
  has_many :order_items
  has_many :products, through: :order_items
end
