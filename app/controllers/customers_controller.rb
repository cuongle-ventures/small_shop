class CustomersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy]
  before_action :authenticate_request

  def index
    @customers = Customer.paginate(query_params)

    render json: { customers: @customers }, status: :ok
  rescue ::PaginateError => e
    render json: { errors: [e.message] }
  end

  def show
    @customer = Customer.find_by(id: params[:id])

    unless @customer.present?
      return render json: { errors: ['customer not found'] }, status: :not_found
    end

    render json: { customer: @customer }, status: :ok
  end

  def create
    @customer = Customer.new(create_params)

    unless @customer.save
      return render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
    end

    render json: { customer: @customer }, status: :ok
  end

  def update
    @customer = find_customer_by_id params[:id]
    
    unless @customer.present?
      return render json: { errors: ['customer not found'] }, status: :not_found   
    end

    unless @customer.update(update_params)
      return render json: { errors: @customer }, status: :unprocessable_entity
    end

    render json: { customer: @customer }, status: :ok
  end

  def destroy
    @customer = find_customer_by_id params[:id]

    unless @customer.present?
      return render json: { errors: ['customer not found'] }, status: :not_found
    end

    @customer.destroy

    render json: {}, status: :ok
  end

  private

  def find_customer_by_id(id)
    customer = Customer.find_by(id: id)
    Rails.logger.info "logger #{customer}"
    customer
  end
  
  def create_params
    params.require(:customer).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def update_params
    params.require(:customer).permit(:first_name, :last_name, :email)
  end

  def query_params
    params.permit(:page, :per_page, :sort_column, :direction, :query)
  end

  private

  def customer_service
    
  end
end
