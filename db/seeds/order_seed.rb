# Order and OrderItem seed data
class OrderSeed
  def self.create_orders(count, min_items_per_order = 1, max_items_per_order = 5)
    puts "Creating #{count} sample orders with order items (#{min_items_per_order}-#{max_items_per_order} items per order)..."

    # Check if users and products exist (memory efficient)
    user_count = User.count
    product_count = Product.count

    if user_count == 0 || product_count == 0
      puts "❌ Error: Users and Products must be created first!"
      return
    end

    puts "Found #{user_count} users and #{product_count} products for order generation"

    # Order statuses with weighted distribution
    # Create weighted array: 10% pending, 20% processing, 30% shipped, 35% delivered, 5% cancelled
    weighted_statuses = ["pending"] * 10 + ["processing"] * 20 + ["shipped"] * 30 + ["delivered"] * 35 + ["cancelled"] * 5

    count.times do |i|
      # Select random user (memory efficient)
      user = User.offset(rand(user_count)).first

      # Select random status from weighted array
      status = weighted_statuses.sample

      # Create order with random date in the last 6 months
      order_date = rand(6.months.ago..Time.current)

      order = Order.create!(
        user: user,
        status: status,
        total_price: 0.0,  # Will be calculated after adding items
        created_at: order_date,
        updated_at: order_date
      )

      # Add configurable range of unique random products to the order
      num_items = rand(min_items_per_order..max_items_per_order)
      order_total = 0.0
      
      # Memory efficient: select random products without loading all into memory
      selected_product_ids = []
      num_items.times do
        # Keep trying until we get a unique product for this order
        loop do
          random_product_id = Product.offset(rand(product_count)).pluck(:id).first
          unless selected_product_ids.include?(random_product_id)
            selected_product_ids << random_product_id
            break
          end
        end
      end
      
      # Process each selected product
      selected_product_ids.each do |product_id|
        product = Product.find(product_id)
        quantity = rand(1..3)
        unit_price = product.price
        item_total = unit_price * quantity
        
        OrderItem.create!(
          order: order,
          product: product,
          quantity: quantity,
          unit_price: unit_price
        )
        
        order_total += item_total
      end

      # Update order total
      order.update!(total_price: order_total)

      print "."
    end

    puts "\n✅ Successfully created #{Order.count} orders!"
    puts "📦 Order status distribution:"
    Order.group(:status).count.each do |status, count|
      puts "   #{status.capitalize}: #{count}"
    end
    puts "💰 Total order value: $#{Order.sum(:total_price).round(2)}"
    puts "📊 Average order value: $#{(Order.sum(:total_price) / Order.count).round(2)}"
    puts "🛒 Total order items: #{OrderItem.count}"
    puts "📈 Sample orders:"
    Order.includes(:user, :order_items).limit(3).each do |order|
      puts "   Order ##{order.id} - #{order.user.full_name} - #{order.status} - $#{order.total_price} (#{order.order_items.count} items)"
    end
  end
end
