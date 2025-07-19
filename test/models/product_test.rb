require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @product = Product.new(
      name: "Gaming Laptop",
      price: 1299.99,
      description: "High-performance gaming laptop with RTX graphics",
      stock: 50
    )
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @product.valid?
  end

  test "should require name" do
    @product.name = nil
    assert_not @product.valid?
    assert_includes @product.errors[:name], "can't be blank"
  end

  test "should require price" do
    @product.price = nil
    assert_not @product.valid?
    assert_includes @product.errors[:price], "can't be blank"
  end

  test "should require stock" do
    @product.stock = nil
    assert_not @product.valid?
    assert_includes @product.errors[:stock], "can't be blank"
  end

  test "should require positive price" do
    @product.price = 0
    assert_not @product.valid?
    assert_includes @product.errors[:price], "must be greater than 0"
    
    @product.price = -10
    assert_not @product.valid?
    assert_includes @product.errors[:price], "must be greater than 0"
  end

  test "should allow zero or positive stock" do
    @product.stock = 0
    assert @product.valid?
    
    @product.stock = 10
    assert @product.valid?
  end

  test "should not allow negative stock" do
    @product.stock = -1
    assert_not @product.valid?
    assert_includes @product.errors[:stock], "must be greater than or equal to 0"
  end

  test "should allow decimal prices" do
    @product.price = 99.99
    assert @product.valid?
    
    @product.price = 1000.50
    assert @product.valid?
  end

  # Association Tests
  test "should have many order_items" do
    assert_respond_to @product, :order_items
  end

  test "should have many orders through order_items" do
    assert_respond_to @product, :orders
  end

  # Search Functionality Tests
  test "search_in_name_and_desc should return all products when query is blank" do
    @product.save!
    
    results = Product.search_in_name_and_desc("")
    assert_includes results, @product
    
    results = Product.search_in_name_and_desc(nil)
    assert_includes results, @product
  end

  test "search_in_name_and_desc should find products by name" do
    @product.save!
    
    results = Product.search_in_name_and_desc("Gaming")
    assert_includes results, @product
    
    results = Product.search_in_name_and_desc("Laptop")
    assert_includes results, @product
  end

  test "search_in_name_and_desc should find products by description" do
    @product.save!
    
    results = Product.search_in_name_and_desc("RTX")
    assert_includes results, @product
    
    results = Product.search_in_name_and_desc("graphics")
    assert_includes results, @product
  end

  test "search_in_name_and_desc should return empty for non-matching query" do
    @product.save!
    
    results = Product.search_in_name_and_desc("nonexistent")
    assert_not_includes results, @product
  end

  test "search_in_name_and_desc should be case insensitive" do
    @product.save!
    
    results = Product.search_in_name_and_desc("GAMING")
    assert_includes results, @product
    
    results = Product.search_in_name_and_desc("laptop")
    assert_includes results, @product
  end

  # Edge Cases
  test "should handle very long names" do
    @product.name = "A" * 255
    assert @product.valid?
  end

  test "should handle empty description" do
    @product.description = nil
    assert @product.valid?
    
    @product.description = ""
    assert @product.valid?
  end

  test "should handle large stock numbers" do
    @product.stock = 999999
    assert @product.valid?
  end

  test "should handle high precision prices" do
    @product.price = 9999.99
    assert @product.valid?
  end

  # Business Logic Tests
  test "should calculate correct values for e-commerce scenarios" do
    @product.save
    
    # Test that we can create order items
    user = User.create!(
      email: "test@example.com",
      first_name: "John",
      last_name: "Doe",
      password: "password123"
    )
    
    order = user.orders.create!(status: "pending", total_price: 0)
    order_item = order.order_items.create!(
      product: @product,
      quantity: 2,
      unit_price: @product.price
    )
    
    assert_equal @product.price, order_item.unit_price
    assert_equal @product, order_item.product
  end
end
