class OrderService
  def initialize(customer_email, products)
    @customer_email = customer_email
    @products = products
  end

  def place_order
    @customer = Customer.find_by(email: @customer_email)
    unless @customer.present?
      raise PlaceOrderError.new("customer not found")
    end

    @set = Set[]
    
    @products.each do |product|
      @set.add(product["product_id"])
    end

    if @set.empty?
      raise PlaceOrderError.new("product is an empty array")
    end

    ActiveRecord::Base.transaction do
      @order = Order.new({
        customer_id: @customer.id
      })

      @order.save

      @product_query = Product.where(id: @set.to_a)

      @product_query_hash = @product_query.to_h { |product| [product.id, product] }

      @order_items = []

      @products.each do |product|
        product_details = @product_query_hash[product["product_id"]]
        Rails.logger.info "logger #{product_details.inspect}"  

        order_item = OrderItem.new({
          price: product_details.price,
          quantity: product["quantity"],
          product_id: product_details.id,
          order_id: @order.id
        })

        order_item.save

        @order_items << order_item.as_json(include: :product)
      end

      {
        order: @order,
        items: @order_items
      }
    end
  end
end