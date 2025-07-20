# Product seed data
class ProductSeed
  def self.create_products(count)
    puts "Creating #{count} sample products..."
    
    # Product categories and their typical items
    product_categories = {
      "Electronics" => [
        { name: "Wireless Bluetooth Headphones", price_range: [29.99, 299.99], descriptions: ["High-quality wireless headphones with noise cancellation", "Premium audio experience with long battery life", "Comfortable over-ear design with crystal clear sound"] },
        { name: "Smartphone", price_range: [199.99, 1299.99], descriptions: ["Latest generation smartphone with advanced camera", "High-performance mobile device with 5G connectivity", "Sleek design with powerful processor and long battery"] },
        { name: "Laptop", price_range: [399.99, 2499.99], descriptions: ["High-performance laptop for work and gaming", "Lightweight ultrabook with premium build quality", "Professional laptop with excellent display and keyboard"] },
        { name: "Gaming Mouse", price_range: [19.99, 149.99], descriptions: ["Precision gaming mouse with customizable buttons", "Ergonomic design for extended gaming sessions", "High DPI sensor for competitive gaming"] },
        { name: "Mechanical Keyboard", price_range: [49.99, 299.99], descriptions: ["Premium mechanical keyboard with RGB lighting", "Tactile switches for superior typing experience", "Durable construction with customizable keys"] },
        { name: "4K Monitor", price_range: [199.99, 899.99], descriptions: ["Ultra HD 4K monitor with vibrant colors", "Professional display for creative work", "Gaming monitor with high refresh rate"] },
        { name: "Wireless Charger", price_range: [15.99, 79.99], descriptions: ["Fast wireless charging pad for smartphones", "Sleek design with LED charging indicator", "Universal compatibility with Qi-enabled devices"] },
        { name: "Smart Watch", price_range: [99.99, 799.99], descriptions: ["Advanced fitness tracking with heart rate monitor", "Smartwatch with GPS and cellular connectivity", "Stylish wearable with health monitoring features"] }
      ],
      "Clothing" => [
        { name: "Cotton T-Shirt", price_range: [12.99, 49.99], descriptions: ["Comfortable 100% cotton t-shirt in various colors", "Premium quality fabric with perfect fit", "Casual everyday wear with modern design"] },
        { name: "Denim Jeans", price_range: [29.99, 149.99], descriptions: ["Classic fit denim jeans with premium wash", "Comfortable stretch denim for all-day wear", "Timeless style with modern comfort features"] },
        { name: "Running Shoes", price_range: [49.99, 199.99], descriptions: ["Lightweight running shoes with superior cushioning", "Athletic footwear with breathable mesh upper", "Performance running shoes for serious athletes"] },
        { name: "Winter Jacket", price_range: [79.99, 299.99], descriptions: ["Warm winter jacket with water-resistant coating", "Insulated outerwear for cold weather protection", "Stylish winter coat with premium insulation"] },
        { name: "Casual Sneakers", price_range: [39.99, 129.99], descriptions: ["Comfortable casual sneakers for everyday wear", "Trendy footwear with classic design", "Versatile shoes perfect for any occasion"] },
        { name: "Hoodie", price_range: [24.99, 89.99], descriptions: ["Cozy pullover hoodie with soft fleece lining", "Comfortable sweatshirt for casual wear", "Warm and stylish hoodie in multiple colors"] }
      ],
      "Home & Garden" => [
        { name: "Coffee Maker", price_range: [29.99, 299.99], descriptions: ["Programmable coffee maker with thermal carafe", "Single-serve coffee machine with multiple brew sizes", "Espresso machine for café-quality coffee at home"] },
        { name: "Air Purifier", price_range: [79.99, 399.99], descriptions: ["HEPA air purifier for cleaner indoor air", "Smart air purifier with app control", "Quiet operation air cleaner for bedrooms"] },
        { name: "Garden Tools Set", price_range: [19.99, 89.99], descriptions: ["Complete gardening tool set with carrying case", "Durable hand tools for garden maintenance", "Professional quality tools for serious gardeners"] },
        { name: "LED Desk Lamp", price_range: [24.99, 99.99], descriptions: ["Adjustable LED desk lamp with USB charging", "Modern desk lighting with touch controls", "Energy-efficient lamp with multiple brightness levels"] },
        { name: "Throw Pillow", price_range: [9.99, 39.99], descriptions: ["Decorative throw pillow with premium fabric", "Comfortable accent pillow for sofa or bed", "Stylish home décor pillow in various patterns"] },
        { name: "Storage Basket", price_range: [14.99, 49.99], descriptions: ["Woven storage basket for home organization", "Decorative basket perfect for any room", "Durable storage solution with handles"] }
      ],
      "Books" => [
        { name: "Programming Guide", price_range: [19.99, 79.99], descriptions: ["Comprehensive guide to modern programming languages", "Learn coding with practical examples and projects", "Advanced programming techniques for developers"] },
        { name: "Cookbook", price_range: [15.99, 49.99], descriptions: ["Delicious recipes for home cooking enthusiasts", "International cuisine cookbook with step-by-step instructions", "Healthy cooking recipes for everyday meals"] },
        { name: "Fiction Novel", price_range: [9.99, 29.99], descriptions: ["Captivating fiction novel with compelling characters", "Bestselling novel that will keep you turning pages", "Award-winning fiction from acclaimed author"] },
        { name: "Self-Help Book", price_range: [12.99, 24.99], descriptions: ["Practical guide to personal development and growth", "Transform your life with proven strategies", "Motivational book for achieving your goals"] }
      ],
      "Sports & Outdoors" => [
        { name: "Yoga Mat", price_range: [19.99, 79.99], descriptions: ["Non-slip yoga mat for comfortable practice", "Eco-friendly exercise mat with excellent grip", "Premium yoga mat with alignment guides"] },
        { name: "Water Bottle", price_range: [9.99, 39.99], descriptions: ["Insulated water bottle keeps drinks cold for hours", "BPA-free water bottle with leak-proof design", "Stainless steel bottle perfect for outdoor activities"] },
        { name: "Camping Tent", price_range: [49.99, 299.99], descriptions: ["Waterproof camping tent for outdoor adventures", "Lightweight backpacking tent for hikers", "Family-size tent with easy setup"] },
        { name: "Fitness Tracker", price_range: [29.99, 149.99], descriptions: ["Activity tracker with heart rate monitoring", "Waterproof fitness band with sleep tracking", "Advanced fitness tracker with GPS"] }
      ]
    }

    # Flatten all product templates for easy random selection
    all_product_templates = []
    product_categories.each do |category, items|
      items.each do |item_template|
        all_product_templates << { category: category, template: item_template }
      end
    end
    
    # Prepare batch data for efficient bulk insert
    product_data = []
    current_time = Time.current
    
    # Generate products using simple count.times loop
    count.times do |i|
      # Randomly select a product template
      selected = all_product_templates.sample
      category = selected[:category]
      item_template = selected[:template]
      
      # Generate variations of each item
      variations = ["", "Pro", "Premium", "Deluxe", "Essential", "Classic", "Advanced", "Compact", "Wireless", "Smart"]
      colors = ["Black", "White", "Blue", "Red", "Gray", "Silver", "Gold", "Green"]
      sizes = ["Small", "Medium", "Large", "XL", "Mini", "Standard"]
      
      variation = variations.sample
      color = colors.sample
      size = sizes.sample
      
      # Create product name with variation
      product_name = variation.empty? ? item_template[:name] : "#{variation} #{item_template[:name]}"
      
      # Add color/size for some products
      if ["Clothing", "Electronics"].include?(category) && rand < 0.3
        if category == "Clothing"
          product_name += " - #{color} #{size}"
        else
          product_name += " - #{color}"
        end
      end
      
      # Generate price within range
      min_price, max_price = item_template[:price_range]
      price = rand(min_price..max_price).round(2)
      
      # Generate stock (some out of stock, some low stock, some high stock)
      stock_probability = rand
      stock = if stock_probability < 0.05  # 5% out of stock
        0
      elsif stock_probability < 0.15  # 10% low stock
        rand(1..5)
      elsif stock_probability < 0.35  # 20% medium stock
        rand(6..20)
      else  # 65% good stock
        rand(21..100)
      end
      
      # Select random description with variation
      description = item_template[:descriptions].sample
      description_variations = [
        "#{description} Perfect for daily use.",
        "#{description} High quality and durable.",
        "#{description} Great value for money.",
        "#{description} Customer favorite!",
        "#{description} Limited time offer.",
        description
      ]
      
      final_description = description_variations.sample
      
      # Add to batch data instead of creating immediately
      product_data << {
        name: product_name,
        price: price,
        description: final_description,
        stock: stock,
        created_at: current_time,
        updated_at: current_time
      }

      # Insert in batches of 100
      if product_data.size >= 100
        Product.insert_all(product_data)
        product_data = []  # Reset the array
      end
      
      print "."
    end
    
    # Insert any remaining products in the final batch
    Product.insert_all(product_data) if product_data.any?
    
    puts "\n✅ Successfully created #{Product.count} products!"
    puts "📊 Stock distribution:"
    puts "   Out of stock: #{Product.where(stock: 0).count}"
    puts "   Low stock (1-5): #{Product.where(stock: 1..5).count}"
    puts "   Medium stock (6-20): #{Product.where(stock: 6..20).count}"
    puts "   High stock (21+): #{Product.where('stock > 20').count}"
    puts "💰 Price range: $#{Product.minimum(:price)} - $#{Product.maximum(:price)}"
  end
end
