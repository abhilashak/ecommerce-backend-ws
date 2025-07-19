class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /products
  def index
    @products = Product.all
    
    # Handle search query
    if params[:search].present?
      @products = Product.search_in_name_and_desc(params[:search])
    end
    
    # Handle filtering
    @products = @products.where("stock > 0") if params[:in_stock] == "true"
    @products = @products.where("price >= ?", params[:min_price]) if params[:min_price].present?
    @products = @products.where("price <= ?", params[:max_price]) if params[:max_price].present?
    
    # Handle sorting
    case params[:sort_by]
    when "price_asc"
      @products = @products.order(price: :asc)
    when "price_desc"
      @products = @products.order(price: :desc)
    when "name"
      @products = @products.order(name: :asc)
    when "newest"
      @products = @products.order(created_at: :desc)
    else
      @products = @products.order(:name)
    end
    
    # Pagination
    @products = @products.limit(params[:limit] || 20).offset(params[:offset] || 0)
    
    render json: {
      products: @products.as_json(include: [:order_items]),
      total_count: Product.count,
      filtered_count: @products.count
    }
  end

  # GET /products/:id
  def show
    render json: @product.as_json(include: [:order_items])
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
    
    @products = Product.search_in_name_and_desc(query)
    @products = @products.limit(params[:limit] || 10)
    
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
