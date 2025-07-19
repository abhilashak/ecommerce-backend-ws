require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
    @valid_attributes = {
      name: "Test Product",
      price: 29.99,
      description: "Test description",
      stock: 25
    }
    @invalid_attributes = {
      name: "",
      price: -1,
      description: "",
      stock: -5
    }
  end

  # INDEX Tests
  test "should get index" do
    get products_path, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.key?("products")
    assert json_response.key?("total_count")
    assert json_response.key?("filtered_count")
  end

  test "should get index with search" do
    get products_path, params: { search: "Gaming" }, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response["products"].any? { |p| p["name"].include?("Gaming") }
  end

  test "should get index with price filters" do
    get products_path, params: { min_price: 50, max_price: 100 }, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    json_response["products"].each do |product|
      price = product["price"].to_f
      assert price >= 50
      assert price <= 100
    end
  end

  test "should get index with stock filter" do
    get products_path, params: { in_stock: "true" }, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    json_response["products"].each do |product|
      assert product["stock"] > 0
    end
  end

  test "should get index with sorting" do
    get products_path, params: { sort_by: "price_asc" }, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    products = json_response["products"]
    prices = products.map { |p| p["price"].to_f }
    assert_equal prices.sort, prices
  end

  test "should get index with pagination" do
    get products_path, params: { limit: 1, offset: 0 }, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["products"].length
  end

  # SHOW Tests
  test "should show product" do
    get product_url(@product), as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @product.name, json_response["name"]
    assert_equal @product.price.to_s, json_response["price"]
  end

  test "should return 404 for non-existent product" do
    get product_url(id: 99999), as: :json
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert_equal "Product not found", json_response["error"]
  end

  # CREATE Tests
  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: @valid_attributes }, as: :json
    end
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal @valid_attributes[:name], json_response["name"]
  end

  test "should not create product with invalid attributes" do
    assert_no_difference("Product.count") do
      post products_url, params: { product: @invalid_attributes }, as: :json
    end
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response.key?("errors")
  end

  # UPDATE Tests
  test "should update product" do
    patch product_url(@product), params: { product: { name: "Updated Name" } }, as: :json
    assert_response :success
    
    @product.reload
    assert_equal "Updated Name", @product.name
  end

  test "should not update product with invalid attributes" do
    patch product_url(@product), params: { product: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.key?("errors")
  end

  # DESTROY Tests
  test "should destroy product without orders" do
    # Create a product without any order items
    product = Product.create!(@valid_attributes)
    
    assert_difference("Product.count", -1) do
      delete product_url(product), as: :json
    end
    
    assert_response :no_content
  end

  test "should not destroy product with existing orders" do
    # Use fixture product that has order items
    assert_no_difference("Product.count") do
      delete product_url(@product), as: :json
    end
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "Cannot delete product with existing orders", json_response["error"]
  end

  # SEARCH Tests
  test "should search products" do
    get search_products_path, params: { q: "Gaming" }, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.key?("products")
    assert json_response.key?("query")
    assert json_response.key?("count")
    assert_equal "Gaming", json_response["query"]
  end

  test "should return error for empty search query" do
    get search_products_path, params: { q: "" }, headers: { 'Accept' => 'application/json' }
    assert_response :bad_request
    
    json_response = JSON.parse(response.body)
    assert_equal "Search query is required", json_response["error"]
  end

  test "should limit search results" do
    get search_products_path, params: { q: "Gaming", limit: 1 }, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response["products"].length <= 1
  end

  # LOW_STOCK Tests
  test "should get low stock products" do
    get low_stock_products_path, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.key?("products")
    assert json_response.key?("threshold")
    assert json_response.key?("count")
  end

  test "should get low stock products with custom threshold" do
    get low_stock_products_path, params: { threshold: 60 }, headers: { 'Accept' => 'application/json' }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 60, json_response["threshold"].to_i
    json_response["products"].each do |product|
      assert product["stock"] <= 60
    end
  end

  # Module Integration Tests
  test "should handle complex filtering and sorting" do
    get products_path, params: {
      search: "Gaming",
      min_price: 40,
      sort_by: "price_desc",
      limit: 5
    }, headers: { 'Accept' => 'application/json' }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    
    # Verify search worked
    assert json_response["products"].any? { |p| p["name"].include?("Gaming") }
    
    # Verify price filter worked
    json_response["products"].each do |product|
      assert product["price"].to_f >= 40
    end
    
    # Verify sorting worked (price descending)
    prices = json_response["products"].map { |p| p["price"].to_f }
    assert_equal prices.sort.reverse, prices
    
    # Verify limit worked
    assert json_response["products"].length <= 5
  end
end
