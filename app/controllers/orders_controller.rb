class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:place_order, :destroy]

  before_action :authenticate_request
  before_action :order_service

  include Params

  def index
    render json: { orders: @order_service.listing(paginate_params) }
  rescue ::PaginateError => e
    render json: { errors: [e.message] }
  end

  def destroy
    order_service.destroy(params[:id])
  rescue StandardError => e
    render json: { errors: [e.message] }
  end

  def show
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
    @order = @order_service.place_order(params[:products])
    render json: { data: @order }
  rescue ::PlaceOrderError => e
    render json: { errors: e.messages }
  end

  private

  def order_service
    @order_service = OrderService.new(Current.customer)
  end
end
