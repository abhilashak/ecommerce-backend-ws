class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order

  # Add this line to associate order items with users through orders
  has_one :user, through: :order

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }

  # Calculate total price for this line item
  def total_price
    quantity * unit_price
  end

  # Set unit_price from product price before validation
  before_validation :set_unit_price_from_product, on: :create

  # Update order total_price when order_item changes
  after_save :update_order_total
  after_destroy :update_order_total

  private

  def set_unit_price_from_product
    self.unit_price = product.price if product && unit_price.blank?
  end

  def update_order_total
    order.update_total_price! if order
  end
end
