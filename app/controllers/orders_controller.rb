class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:place_order]
  before_action :authenticate_request

  include Params

  def index
    @customer = Customer.find_by(email: Current.customer["email"])
    @order_service = customer_service

    render json: { orders: @order_service.listing(paginate_params) }
  rescue ::PaginateError => e
    render json: { errors: [e.message] }
  end

  def show
    @order_service = customer_service

    @order = @order_service.show(params[:id])

    unless @order.present?
      return render json: { errors: ['order not found'] }
    end

    @order_arr = []

    @order.order_items.each do |ot|
      @order_arr << {
        product: ot.product.name,
        price: ot.price,
        quantity: ot.quantity,
        total: ot.price * ot.quantity,
        created_at: ot.created_at,
        updated_at: ot.updated_at
      }
    end

    render json: { order: @order.as_json(include: {
      customer: {
        only: [:id, :email]
      }
    }), items: @order_arr }
  end

  def place_order
    @customer = Customer.find_by(email: Current.customer["email"])
    @order_service = customer_service
    @order = @order_service.place_order(params[:products])
    render json: { data: @order }
  rescue ::PlaceOrderError => e
    render json: { errors: e.messages }
  end

  private

  def customer_service
    customer = Customer.find_by(email: Current.customer["email"])
    OrderService.new(customer)
  end
end
