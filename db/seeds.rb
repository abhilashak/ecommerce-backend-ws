# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Load seed files
Dir[Rails.root.join('db', 'seeds', '*.rb')].each { |f| require f }
require_relative 'seeds/clear_seed'

class SeedData
  include ClearSeed
  # Configuration
  RECORD_COUNT = 100

  def call
    puts "🌱 Starting database seeding with #{RECORD_COUNT} records each..."
    puts "=" * 60

    # clear the existing data
    clear_existing_data

    # Create seed data in order (users first, then products, then orders)
    # 1. Create Users
    UserSeed.create_users(RECORD_COUNT)
    puts "=" * 60

    # 2. Create Products
    ProductSeed.create_products(RECORD_COUNT)
    puts "=" * 60

    # 3. Create Orders and Order Items
    OrderSeed.create_orders(RECORD_COUNT)
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
