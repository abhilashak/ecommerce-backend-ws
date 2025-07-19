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

    # Try full-text search first, fall back to ILIKE if searchable column is not populated
    if connection.column_exists?(:products, :searchable) && 
       exists?("searchable IS NOT NULL")
      sanitized_query = connection.quote(query)
      where("searchable @@ plainto_tsquery('english', ?)", query)
        .order(Arel.sql("ts_rank(searchable, plainto_tsquery('english', #{sanitized_query})) DESC"))
    else
      # Fallback to ILIKE search for name and description
      where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
        .order(:name)
    end
  end
end
