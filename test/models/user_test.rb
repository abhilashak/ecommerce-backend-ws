require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      first_name: "John",
      last_name: "Doe",
      password: "password123",
      phone: "1234567890"
    )
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require first_name" do
    @user.first_name = nil
    assert_not @user.valid?
    assert_includes @user.errors[:first_name], "can't be blank"
  end

  test "should require last_name" do
    @user.last_name = nil
    assert_not @user.valid?
    assert_includes @user.errors[:last_name], "can't be blank"
  end

  test "should require unique email" do
    @user.save
    duplicate_user = User.new(
      email: "test@example.com",
      first_name: "Jane",
      last_name: "Smith",
      password: "password123"
    )
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should validate email format" do
    invalid_emails = ["invalid", "@example.com", "test@", "test.example.com"]
    
    invalid_emails.each do |email|
      @user.email = email
      assert_not @user.valid?, "#{email} should be invalid"
      assert_includes @user.errors[:email], "is invalid"
    end
  end

  test "should accept valid email formats" do
    valid_emails = ["test@example.com", "user.name@domain.co.uk", "test+tag@example.org"]
    
    valid_emails.each do |email|
      @user.email = email
      assert @user.valid?, "#{email} should be valid"
    end
  end

  test "should require password with minimum length" do
    @user.password = "short"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "should accept password with 8 or more characters" do
    @user.password = "password123"
    assert @user.valid?
  end

  # Association Tests
  test "should have many orders" do
    assert_respond_to @user, :orders
  end

  test "should have many order_items through orders" do
    assert_respond_to @user, :order_items
  end

  test "should have many products through order_items" do
    assert_respond_to @user, :products
  end

  test "should restrict deletion when user has orders" do
    @user.save
    order = @user.orders.create(status: "pending", total_price: 100.0)
    
    assert_not @user.destroy
    assert_includes @user.errors[:base], "Cannot delete record because dependent orders exist"
    assert User.exists?(@user.id)
    assert Order.exists?(order.id), "Order should still exist after failed user deletion"
  end

  test "should allow deletion when user has no orders" do
    @user.save
    user_id = @user.id
    
    assert @user.destroy
    assert_not User.exists?(user_id)
  end

  # Method Tests
  test "full_name should return concatenated first and last name" do
    assert_equal "John Doe", @user.full_name
  end

  test "full_name should handle nil names gracefully" do
    @user.first_name = nil
    @user.last_name = "Doe"
    assert_equal "Doe", @user.full_name
    
    @user.first_name = "John"
    @user.last_name = nil
    assert_equal "John", @user.full_name
  end

  test "full_name should strip whitespace" do
    @user.first_name = " John "
    @user.last_name = " Doe "
    assert_equal "John   Doe", @user.full_name.strip
  end

  # Authentication Tests
  test "should authenticate with correct password" do
    @user.save
    assert @user.authenticate("password123")
  end

  test "should not authenticate with incorrect password" do
    @user.save
    assert_not @user.authenticate("wrongpassword")
  end

  test "should have encrypted password_digest" do
    @user.save
    assert_not_nil @user.password_digest
    assert_not_equal "password123", @user.password_digest
  end
end
