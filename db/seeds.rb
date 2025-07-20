# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load seed files
Dir[Rails.root.join('db', 'seeds', '*.rb')].each { |f| require f }
require_relative 'seeds/clear_seed'

class SeedData
  include ClearSeed
  
  # ===== CENTRALIZED CONFIGURATION =====
  # Main record counts - adjust these to scale your seed data
  USER_COUNT = 10000            # Number of users to create
  PRODUCT_COUNT = 10000         # Number of products to create
  ORDER_COUNT = 100000          # Number of orders to create
  
  # Derived counts (calculated from base counts)
  MIN_ORDER_ITEMS_PER_ORDER = 1
  MAX_ORDER_ITEMS_PER_ORDER = 5
  EXPECTED_ORDER_ITEMS = ORDER_COUNT * ((MIN_ORDER_ITEMS_PER_ORDER + MAX_ORDER_ITEMS_PER_ORDER) / 2.0)
  
  # ===== SEED CONFIGURATION OBJECT =====
  def seed_config
    {
      user_count: USER_COUNT,
      product_count: PRODUCT_COUNT,
      order_count: ORDER_COUNT,
      min_order_items_per_order: MIN_ORDER_ITEMS_PER_ORDER,
      max_order_items_per_order: MAX_ORDER_ITEMS_PER_ORDER,
      expected_order_items: EXPECTED_ORDER_ITEMS.to_i
    }
  end

  def call
    config = seed_config
    puts "🌱 Starting database seeding with centralized configuration..."
    puts "📊 Seed Configuration:"
    puts "   👥 Users: #{config[:user_count]}"
    puts "   📦 Products: #{config[:product_count]}"
    puts "   🛒 Orders: #{config[:order_count]}"
    puts "   📋 Expected Order Items: ~#{config[:expected_order_items]}"
    puts "=" * 60

    # clear the existing data
    clear_existing_data

    # Create seed data in order (users first, then products, then orders)
    # 1. Create Users
    UserSeed.create_users(config[:user_count])
    puts "=" * 60

    # 2. Create Products
    ProductSeed.create_products(config[:product_count])
    puts "=" * 60

    # 3. Create Orders and Order Items
    OrderSeed.create_orders(config[:order_count], config[:min_order_items_per_order], config[:max_order_items_per_order])
    puts "=" * 60
  end

  # Final summary
  def summary
    puts "🎉 Database seeding completed successfully!"
    puts "📊 Final Summary:"
    puts "   👥 Users: #{User.count}"
    puts "   📦 Products: #{Product.count}"
    puts "   🛒 Orders: #{Order.count}"
    puts "   📋 Order Items: #{OrderItem.count}"
    puts "   💰 Total Sales: $#{Order.sum(:total_price).round(2)}"
    puts "=" * 60
  end
end

# seed the data
SeedData.new.call
