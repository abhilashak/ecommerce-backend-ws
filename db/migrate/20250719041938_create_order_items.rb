class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.references :product, null: false, foreign_key: { on_delete: :restrict }
      t.references :order, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    # Add indexes for performance
    add_index :order_items, :product_id, name: "idx_order_items_product_id"
    add_index :order_items, :order_id, name: "idx_order_items_order_id"
    add_index :order_items, [ :order_id, :product_id ], unique: true, name: 'idx_order_items_on_order_and_product'

    # Add constraints
    add_check_constraint :order_items, "quantity > 0", name: "constraint_order_items_quantity_positive"
    add_check_constraint :order_items, "unit_price > 0", name: "constraint_order_items_unit_price_positive"
  end
end
