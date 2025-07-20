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

    # Pre-compute expensive operations (MAJOR PERFORMANCE BOOST)
    current_time = Time.current
    six_months_ago = 6.months.ago
    
    # Cache user and product IDs to avoid repeated database queries
    puts "Caching user and product IDs for performance..."
    user_ids = User.pluck(:id)
    product_ids_with_prices = Product.pluck(:id, :price).to_h  # Hash for O(1) price lookup
    
    # Prepare batch data for efficient bulk insert
    order_data = []
    order_item_data = []
    
    count.times do |i|
      # Select random user (from cached array - much faster)
      user_id = user_ids.sample

      # Select random status from weighted array
      status = weighted_statuses.sample

      # Create order with random date in the last 6 months (using cached times)
      order_date = rand(six_months_ago..current_time)

      # Add configurable range of unique random products to the order
      num_items = rand(min_items_per_order..max_items_per_order)
      order_total = 0.0
      
      # Memory efficient: select random products from cached IDs (much faster)
      available_product_ids = product_ids_with_prices.keys
      selected_product_ids = available_product_ids.sample(num_items)  # Ensures uniqueness
      
      # Calculate order total and prepare order items data
      selected_product_ids.each do |product_id|
        product_price = product_ids_with_prices[product_id]  # O(1) hash lookup instead of database query
        quantity = rand(1..3)
        unit_price = product_price
        item_total = unit_price * quantity
        
        # Add to order items batch data (we'll set order_id after orders are created)
        order_item_data << {
          order_index: i,  # Temporary reference to match with order
          product_id: product_id,
          quantity: quantity,
          unit_price: unit_price,
          created_at: order_date,
          updated_at: order_date
        }
        
        order_total += item_total
      end

      # Add to orders batch data
      order_data << {
        user_id: user_id,
        status: status,
        total_price: order_total,
        created_at: order_date,
        updated_at: order_date
      }

      # Insert in batches of 100
      if order_data.size >= 100
        Order.insert_all(order_data)
        order_data = []  # Reset the array
        
        print "."
      end

    end
    
    # Insert any remaining orders in the final batch
    Order.insert_all(order_data) if order_data.any?
    
    # Get the created order IDs to link with order items
    created_orders = Order.order(:id).last(count)
    
    # Update order_item_data with actual order_ids
    order_item_data.each do |item|
      order_index = item.delete(:order_index)
      item[:order_id] = created_orders[order_index].id
    end
    
    # Batch insert all order items at once
    OrderItem.insert_all(order_item_data) if order_item_data.any?

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
