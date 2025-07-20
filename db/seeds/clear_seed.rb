module ClearSeed
  def clear_existing_data
    # Clear existing data efficiently (much faster for large datasets)
    puts "🧹 Clearing existing data..."
    
    # Use delete_all for performance - single SQL DELETE statements
    # No callbacks or validations needed for seed data cleanup
    puts "  Clearing order items..."
    OrderItem.delete_all
    
    puts "  Clearing orders..."
    Order.delete_all
    
    puts "  Clearing products..."
    Product.delete_all
    
    puts "  Clearing users..."
    User.delete_all

    # Reset auto-increment counters (PostgreSQL)
    ActiveRecord::Base.connection.reset_pk_sequence!('users')
    ActiveRecord::Base.connection.reset_pk_sequence!('products')
    ActiveRecord::Base.connection.reset_pk_sequence!('orders')
    ActiveRecord::Base.connection.reset_pk_sequence!('order_items')

    puts "✅ Database cleared successfully!"
    puts "=" * 60
  end
end
