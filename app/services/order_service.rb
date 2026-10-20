class OrderService
  attr_reader :customer

  def initialize(customer)
    @customer = customer
  end

  def listing(params)
    orders = Order.paginate(params)
    orders
  end

  def show(id)
    order = Order.find_by(id: id)
    order
  end

  def destroy(id)
    order = show(id)

    unless order.present?
      raise StandardError.new("order not found")
    end

    order.destroy
  end

  def place_order(products)
    unless @customer.present?
      raise PlaceOrderError.new("customer not found")
    end

    if products.count == 0
      raise PlaceOrderError.new("product is an empty array")
    end

    @errors = []
    @set = Set[]
    
    products.each do |product|
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

      products.each do |product| 
        product_details = @product_query_hash[product["product_id"]]

        unless product_details.present?
          @errors << "product id #{product["product_id"]} is not found"
        end
      end

      if @errors.count > 0
        raise PlaceOrderError.new(@errors)
      end

      @order_items = []

      products.each do |product|
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