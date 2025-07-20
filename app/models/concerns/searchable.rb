module Searchable
  extend ActiveSupport::Concern

  class_methods do
    # Search across specified fields with full-text search support
    # @param query [String] search term
    # @param fields [Array<Symbol>] fields to search in (default: [:name, :description])
    # @param searchable_column [Symbol] full-text search column name (default: :searchable)
    # @return [ActiveRecord::Relation] matching records ordered by relevance
    def search_in_fields(query, fields: [ :name, :description ], searchable_column: :searchable)
      return all if query.blank?

      # Try full-text search first if searchable column exists and is populated
      if connection.column_exists?(table_name, searchable_column) &&
         where.not(searchable_column => nil).exists?
        full_text_search(query, searchable_column)
      else
        # Fallback to ILIKE search across specified fields
        ilike_search(query, fields)
      end
    end

    # Convenience method for name and description search (backward compatibility)
    # @param query [String] search term
    # @return [ActiveRecord::Relation] matching records ordered by relevance
    def search_in_name_and_desc(query)
      search_in_fields(query, fields: [ :name, :description ])
    end

    private

    # Full-text search using PostgreSQL's text search capabilities
    # @param query [String] search term
    # @param searchable_column [Symbol] column containing searchable text
    # @return [ActiveRecord::Relation] matching records ordered by relevance
    def full_text_search(query, searchable_column)
      sanitized_query = connection.quote(query)
      where("#{searchable_column} @@ plainto_tsquery('english', ?)", query)
        .order(Arel.sql("ts_rank(#{searchable_column}, plainto_tsquery('english', #{sanitized_query})) DESC"))
    end

    # ILIKE search across multiple fields
    # @param query [String] search term
    # @param fields [Array<Symbol>] fields to search in
    # @return [ActiveRecord::Relation] matching records ordered by first field
    def ilike_search(query, fields)
      conditions = fields.map { |field| "#{field} ILIKE ?" }
      values = Array.new(fields.length, "%#{query}%")

      where(conditions.join(" OR "), *values)
        .order(fields.first)
    end
  end
end
