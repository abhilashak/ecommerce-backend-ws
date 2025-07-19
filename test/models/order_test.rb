require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      first_name: "John",
      last_name: "Doe",
      password: "password123"
    )
    
    @order = Order.new(
      user: @user,
      status: "pending",
      total_price: 100.0
    )
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @order.valid?
  end

  test "should require user" do
    @order.user = nil
    assert_not @order.valid?
    assert_includes @order.errors[:user], "must exist"
  end

  test "should require status" do
    @order.status = nil
    assert_not @order.valid?
    assert_includes @order.errors[:status], "can't be blank"
  end

  test "should require total_price" do
    @order.total_price = nil
    assert_not @order.valid?
    assert_includes @order.errors[:total_price], "can't be blank"
  end

  test "should require non-negative total_price" do
    @order.total_price = -10
    assert_not @order.valid?
    assert_includes @order.errors[:total_price], "must be greater than or equal to 0"
  end

  test "should allow zero total_price" do
    @order.total_price = 0
    assert @order.valid?
  end

  # Enum Tests
  test "should have correct status enum values" do
    expected_statuses = %w[pending processing shipped delivered cancelled]
    assert_equal expected_statuses, Order.statuses.keys
  end

  test "should set status using enum" do
    @order.status = "processing"
    assert_equal "processing", @order.status
    assert @order.processing?
    
    @order.status = "shipped"
    assert_equal "shipped", @order.status
    assert @order.shipped?
  end

  test "should validate status inclusion" do
    assert_raises(ArgumentError) do
      @order.status = "invalid_status"
    end
  end

  # Association Tests
  test "should belong to user" do
    assert_respond_to @order, :user
    assert_equal @user, @order.user
  end

  test "should have many order_items" do
    assert_respond_to @order, :order_items
  end

  test "should have many products through order_items" do
    assert_respond_to @order, :products
  end

  test "should destroy order_items when order is destroyed" do
    @order.save!
    
    product = Product.create!(
      name: "Test Product",
      price: 50.0,
      stock: 10
    )
    
    order_item = @order.order_items.create!(
      product: product,
      quantity: 2,
      unit_price: product.price
    )
    
    order_item_id = order_item.id
    @order.destroy
    
    assert_not OrderItem.exists?(order_item_id)
  end

  # Business Logic Tests
  test "calculate_total_price should sum all order items" do
    @order.save!
    
    product1 = Product.create!(name: "Product 1", price: 25.0, stock: 10)
    product2 = Product.create!(name: "Product 2", price: 15.0, stock: 10)
    
    @order.order_items.create!(product: product1, quantity: 2, unit_price: 25.0)
    @order.order_items.create!(product: product2, quantity: 3, unit_price: 15.0)
    
    expected_total = (2 * 25.0) + (3 * 15.0) # 50 + 45 = 95
    assert_equal expected_total, @order.calculate_total_price
  end

  test "calculate_total_price should return zero for order with no items" do
    @order.save!
    assert_equal 0, @order.calculate_total_price
  end

  test "update_total_price! should update total_price from order items" do
    @order.save!
    
    product = Product.create!(name: "Test Product", price: 30.0, stock: 10)
    @order.order_items.create!(product: product, quantity: 2, unit_price: 30.0)
    
    @order.update_total_price!
    @order.reload
    
    assert_equal 60.0, @order.total_price
  end

  # Status Transition Tests
  test "should allow valid status transitions" do
    @order.save!
    
    # pending -> processing
    @order.update!(status: "processing")
    assert @order.processing?
    
    # processing -> shipped
    @order.update!(status: "shipped")
    assert @order.shipped?
    
    # shipped -> delivered
    @order.update!(status: "delivered")
    assert @order.delivered?
  end

  test "should allow cancellation from any status" do
    @order.save!
    
    %w[pending processing shipped].each do |status|
      @order.update!(status: status)
      @order.update!(status: "cancelled")
      assert @order.cancelled?
    end
  end

  # Edge Cases
  test "should handle decimal total_price" do
    @order.total_price = 99.99
    assert @order.valid?
  end

  test "should handle large total_price" do
    @order.total_price = 9999.99
    assert @order.valid?
  end

  # Integration Tests
  test "should work with complete order flow" do
    @order.save!
    
    # Add products to order
    product1 = Product.create!(name: "Laptop", price: 1000.0, stock: 5)
    product2 = Product.create!(name: "Mouse", price: 25.0, stock: 20)
    
    item1 = @order.order_items.create!(product: product1, quantity: 1, unit_price: 1000.0)
    item2 = @order.order_items.create!(product: product2, quantity: 2, unit_price: 25.0)
    
    # Verify relationships
    assert_equal 2, @order.order_items.count
    assert_includes @order.order_items, item1
    assert_includes @order.order_items, item2
    assert_includes @order.products, product1
    assert_includes @order.products, product2
    
    # Verify total calculation
    expected_total = 1000.0 + (2 * 25.0) # 1050.0
    assert_equal expected_total, @order.calculate_total_price
    
    # Update order total
    @order.update_total_price!
    assert_equal expected_total, @order.total_price
  end
end
