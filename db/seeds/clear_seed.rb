module ClearSeed
  def clear_existing_data
    # Clear existing data
    puts "🧹 Clearing existing data..."
    OrderItem.destroy_all
    Order.destroy_all
    Product.destroy_all
    User.destroy_all

    # Reset auto-increment counters (PostgreSQL)
    ActiveRecord::Base.connection.reset_pk_sequence!('users')
    ActiveRecord::Base.connection.reset_pk_sequence!('products')
    ActiveRecord::Base.connection.reset_pk_sequence!('orders')
    ActiveRecord::Base.connection.reset_pk_sequence!('order_items')

    puts "✅ Database cleared successfully!"
    puts "=" * 60
  end
end
