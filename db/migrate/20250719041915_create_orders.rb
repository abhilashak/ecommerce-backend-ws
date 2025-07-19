class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending', limit: 50
      t.decimal :total_price, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end

    # Add indexes for performance
    add_index :orders, :status, name: "idx_orders_status"
    add_index :orders, :total_price, name: "idx_orders_total_price"
    add_index :orders, :created_at, name: "idx_orders_created_at"
    add_index :orders, [ :status, :created_at ], name: "idx_orders_status_created_at"

    # Add constraints
    add_check_constraint :orders, "total_price >= 0", name: "constraint_orders_total_price_non_negative"
  end
end
