# Order and OrderItem seed data
class OrderSeed
  def self.create_orders(count = RECORD_COUNT)
    puts "Creating #{count} sample orders with order items..."

    # Get all users and products
    users = User.all.to_a
    products = Product.all.to_a

    if users.empty? || products.empty?
      puts "❌ Error: Users and Products must be created first!"
      return
    end

    # Order statuses with weighted distribution
    # Create weighted array: 10% pending, 20% processing, 30% shipped, 35% delivered, 5% cancelled
    weighted_statuses = ["pending"] * 10 + ["processing"] * 20 + ["shipped"] * 30 + ["delivered"] * 35 + ["cancelled"] * 5

    count.times do |i|
      # Select random user
      user = users.sample

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

      # Add 1-5 unique random products to the order
      num_items = rand(1..5)
      order_total = 0.0
      selected_products = products.sample(num_items)  # This ensures unique products
      
      selected_products.each do |product|
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
