class ProductsController < ApplicationController
  include ProductFilterable

  before_action :set_product, only: [ :show, :update, :destroy ]

  # GET /products
  def index
    result = get_filtered_products_with_metadata(params)
    render json: result
  end

  # GET /products/:id
  def show
    render json: @product.as_json(include: [ :order_items ])
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/:id
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /products/:id
  def destroy
    if @product.order_items.exists?
      render json: { error: "Cannot delete product with existing orders" }, status: :unprocessable_entity
    else
      @product.destroy
      head :no_content
    end
  end

  # GET /products/search
  def search
    query = params[:q]

    if query.blank?
      render json: { error: "Search query is required" }, status: :bad_request
      return
    end

    search_params = { search: query, limit: params[:limit] || 10 }
    @products = filter_and_sort_products(Product.all, search_params)

    render json: {
      products: @products.as_json,
      query: query,
      count: @products.count
    }
  end

  # GET /products/low_stock
  def low_stock
    threshold = params[:threshold] || 10
    @products = Product.where("stock <= ?", threshold).order(:stock)

    render json: {
      products: @products.as_json,
      threshold: threshold,
      count: @products.count
    }
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end

  def product_params
    params.require(:product).permit(:name, :price, :description, :stock)
  end
end
