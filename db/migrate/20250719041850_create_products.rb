class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false, limit: 255
      t.decimal :price, precision: 10, scale: 2, null: false
      t.text :description
      t.integer :stock, null: false, default: 0

      t.timestamps
    end

    # Add indexes for performance
    add_index :products, [ :stock, :price ], where: "stock > 0", name: "idx_products_available_by_price"
    add_index :products, [ :created_at, :price ], name: "idx_products_created_at_price"
    add_index :products, :stock, name: "idx_products_stock"
    add_index :products, :created_at, name: "idx_products_created_at"

    # Add constraints
    add_check_constraint :products, "price > 0", name: "constraint_products_price_positive"
    add_check_constraint :products, "stock >= 0", name: "constraint_products_stock_non_negative"
    add_check_constraint :products, "length(name) >= 2", name: "constraint_products_name_min_length"
  end
end
