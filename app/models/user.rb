class User < ApplicationRecord
  has_secure_password

  # Validations
  validates :email, presence: true,
                   uniqueness: true,
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  # Associations
  has_many :orders, dependent: :restrict_with_error
  has_many :order_items, through: :orders
  has_many :products, through: :order_items

  # Helper method
  def full_name
    "#{first_name} #{last_name}".strip
  end
end
