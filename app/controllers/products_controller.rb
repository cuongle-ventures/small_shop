class ProductsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy]

  def index
    @products = Product.paginate(query_params)

    render json: { products: @products }, status: :ok
  rescue ::PaginateError => e
    render json: { errors: [e.message] }
  end

  def show
    @product = Product.find_by(id: params[:id])

    unless @product.present?
      return render json: { errors: ['product not found'] }
    end

    render json: { product: @product }
  end

  def create
    @product = Product.new(product_params)

    unless @product.save
      return render json: { errors: @product.errors.full_messages }
    end

    render json: { product: @product }
  end

  def update
    @product = Product.find_by(id: params[:id])

    unless @product.present?
      return render json: { errors: ['product not found'] }
    end

    unless @product.update(product_params)
      return render json: { errors: @product.errors.full_messages }
    end

    render json: { product: @product }
  end

  def destroy
    @product = Product.find_by(id: params[:id])

    unless @product.present?
      return render json: { errors: ['product not found'] }
    end

    @product.update(active: false)

    render json: { product: @product }
  end

  private

  def product_params
    params.require(:product).permit(:name, :price, :active)
  end

  def query_params
    params.permit(:page, :per_page, :sort_column, :direction, :query)
  end
end
