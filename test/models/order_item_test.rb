require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  # Disable parallel execution for this test class due to database callback dependencies
  parallelize(workers: 1)
  def setup
    @user = User.create!(
      email: "test@example.com",
      first_name: "John",
      last_name: "Doe",
      password: "password123"
    )
    
    @product = Product.create!(
      name: "Gaming Mouse",
      price: 49.99,
      description: "High-precision gaming mouse",
      stock: 100
    )
    
    @order = @user.orders.create!(
      status: "pending",
      total_price: 0
    )
    
    @order_item = OrderItem.new(
      product: @product,
      order: @order,
      quantity: 2,
      unit_price: @product.price
    )
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @order_item.valid?
  end

  test "should require product" do
    @order_item.product = nil
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:product], "must exist"
  end

  test "should require order" do
    @order_item.order = nil
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:order], "must exist"
  end

  test "should require quantity" do
    @order_item.quantity = nil
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:quantity], "can't be blank"
  end

  test "should require unit_price" do
    # Create order item without product to avoid callback setting unit_price
    order_item = OrderItem.new(
      order: @order,
      quantity: 1,
      unit_price: nil
    )
    assert_not order_item.valid?
    assert_includes order_item.errors[:unit_price], "can't be blank"
  end

  test "should require positive quantity" do
    @order_item.quantity = 0
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:quantity], "must be greater than 0"
    
    @order_item.quantity = -1
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:quantity], "must be greater than 0"
  end

  test "should require positive unit_price" do
    @order_item.unit_price = 0
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:unit_price], "must be greater than 0"
    
    @order_item.unit_price = -10
    assert_not @order_item.valid?
    assert_includes @order_item.errors[:unit_price], "must be greater than 0"
  end

  # Association Tests
  test "should belong to product" do
    assert_respond_to @order_item, :product
    assert_equal @product, @order_item.product
  end

  test "should belong to order" do
    assert_respond_to @order_item, :order
    assert_equal @order, @order_item.order
  end

  test "should have user through order" do
    assert_respond_to @order_item, :user
    @order_item.save!
    assert_equal @user, @order_item.user
  end

  # Business Logic Tests
  test "total_price should calculate quantity times unit_price" do
    assert_equal 99.98, @order_item.total_price # 2 * 49.99
    
    @order_item.quantity = 3
    assert_equal 149.97, @order_item.total_price # 3 * 49.99
    
    @order_item.unit_price = 25.0
    assert_equal 75.0, @order_item.total_price # 3 * 25.0
  end

  test "should set unit_price from product on create" do
    order_item = OrderItem.new(
      product: @product,
      order: @order,
      quantity: 1
    )
    
    order_item.valid? # Trigger before_validation callback
    assert_equal @product.price, order_item.unit_price
  end

  test "should not override manually set unit_price" do
    custom_price = 39.99
    order_item = OrderItem.new(
      product: @product,
      order: @order,
      quantity: 1,
      unit_price: custom_price
    )
    
    order_item.valid? # Trigger before_validation callback
    assert_equal custom_price, order_item.unit_price
    assert_not_equal @product.price, order_item.unit_price
  end

  test "should update order total when saved" do
    initial_total = @order.total_price
    @order_item.save!
    
    @order.reload
    expected_total = initial_total + @order_item.total_price
    assert_equal expected_total, @order.total_price
  end

  test "should update order total when destroyed" do
    @order_item.save!
    @order.reload
    total_with_item = @order.total_price
    
    @order_item.destroy
    @order.reload
    
    assert_equal 0, @order.total_price
    assert total_with_item > @order.total_price
  end

  test "should update order total when quantity changes" do
    @order_item.save!
    @order.reload
    initial_total = @order.total_price
    
    @order_item.update!(quantity: 3)
    @order.reload
    
    expected_total = 3 * @order_item.unit_price
    assert_equal expected_total, @order.total_price
    assert initial_total < @order.total_price
  end

  # Unique Constraint Tests
  test "should prevent duplicate product in same order" do
    @order_item.save!
    
    duplicate_item = OrderItem.new(
      product: @product,
      order: @order,
      quantity: 1,
      unit_price: @product.price
    )
    
    # The unique constraint is enforced at database level, not validation level
    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate_item.save!
    end
  end

  test "should allow same product in different orders" do
    @order_item.save!
    
    other_order = @user.orders.create!(status: "pending", total_price: 0)
    other_item = OrderItem.new(
      product: @product,
      order: other_order,
      quantity: 1,
      unit_price: @product.price
    )
    
    assert other_item.valid?
    assert other_item.save!
  end

  # Edge Cases
  test "should handle multiple quantities" do
    @order_item.quantity = 10
    assert @order_item.valid?
    # 10 * 49.99 = 499.90
    expected_total = 10 * @order_item.unit_price
    assert_in_delta expected_total, @order_item.total_price, 0.01
  end

  test "should handle high precision unit_price" do
    @order_item.unit_price = 99.999
    assert @order_item.valid?
    assert_in_delta 199.998, @order_item.total_price, 0.01 # 2 * 99.999
  end

  test "should handle large quantities" do
    @order_item.quantity = 1000
    assert @order_item.valid?
    assert_in_delta 49990.0, @order_item.total_price, 0.01 # 1000 * 49.99
  end

  # Integration Tests
  test "should work in complete order scenario" do
    # Create multiple order items
    @order_item.save!
    
    product2 = Product.create!(name: "Keyboard", price: 79.99, stock: 50)
    item2 = @order.order_items.create!(
      product: product2,
      quantity: 1,
      unit_price: product2.price
    )
    
    # Manually trigger order total update to ensure consistency
    @order.update_total_price!
    @order.reload
    
    # Verify we have the correct number of items
    assert_equal 2, @order.order_items.count, "Order should have exactly 2 items"
    
    # Verify individual item totals
    assert_in_delta 99.98, @order_item.total_price, 0.01
    assert_in_delta 79.99, item2.total_price, 0.01
    
    # Verify order total is sum of item totals
    expected_total = @order.order_items.sum(&:total_price)
    assert_in_delta expected_total, @order.total_price, 0.01
    
    # Verify associations work both ways
    assert_includes @order.order_items, @order_item
    assert_includes @order.order_items, item2
    assert_includes @order.products, @product
    assert_includes @order.products, product2
    
    # Verify user can access items through order
    assert_includes @user.order_items, @order_item
    assert_includes @user.order_items, item2
    assert_includes @user.products, @product
    assert_includes @user.products, product2
  end
end
