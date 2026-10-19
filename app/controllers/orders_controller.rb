class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:place_order]
  before_action :authenticate_request, only: [:place_order]

  include Params

  def index
    @orders = Order.paginate(paginate_params)

    render json: { orders: @orders }
  end

  def show
    @order = Order.find_by(id: params[:id])

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
    @order_service = OrderService.new(Current.customer["email"], params[:products])
    @order = @order_service.place_order
    render json: { data: @order }
  rescue ::PlaceOrderError => e
    render json: { errors: [e.message] }
  end
end
