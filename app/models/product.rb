class Product < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Search across both name and description
  # @param query [String] search term
  # @return [ActiveRecord::Relation] matching products ordered by relevance
  def self.search_in_name_and_desc(query)
    return all if query.blank?

    # Search using the tsvector column (maintained by database trigger)
    where("searchable @@ plainto_tsquery('english', ?)", query)
      .order("ts_rank(searchable, plainto_tsquery('english', ?)) DESC", query)
  end
end
