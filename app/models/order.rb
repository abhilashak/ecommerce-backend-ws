class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Define status enum
  enum :status, {
    pending: "pending",
    processing: "processing",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }

  validates :status, presence: true
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Calculate total price from all order items
  def calculate_total_price
    order_items.sum(&:total_price)
  end

  # Update total_price when order_items change
  def update_total_price!
    update!(total_price: calculate_total_price)
  end
end
