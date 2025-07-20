module Searchable
  extend ActiveSupport::Concern

  class_methods do
    # Search across specified fields with full-text search support
    # @param query [String] search term
    # @param fields [Array<Symbol>] fields to search in (default: [:name, :description])
    # @param searchable_column [Symbol] full-text search column name (default: :searchable)
    # @return [ActiveRecord::Relation] matching records ordered by relevance
    def search_in_fields(query, fields: [:name, :description], searchable_column: :searchable)
      return all if query.blank?

      # Try full-text search first if searchable column exists and is populated
      if connection.column_exists?(table_name, searchable_column) && 
         where.not(searchable_column => nil).exists?
        
        # First try full-text search for complete words (best relevance)
        full_text_results = full_text_search(query, searchable_column)
        
        # If full-text search finds results, use it (best performance and relevance)
        if full_text_results.exists?
          full_text_results
        else
          # If no full-text results, fallback to ILIKE for partial matches
          ilike_search(query, fields)
        end
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

    # Full-text search using PostgreSQL's text search capabilities with prefix matching
    # @param query [String] search term
    # @param searchable_column [Symbol] column containing searchable text
    # @return [ActiveRecord::Relation] matching records ordered by relevance
    def full_text_search_with_prefix(query, searchable_column)
      # Clean and prepare the query for prefix matching
      clean_query = query.strip.gsub(/[^\w\s]/, '').squeeze(' ')
      
      # Split into words and add prefix matching (:*) to each word
      words = clean_query.split(/\s+/).map { |word| "#{word}:*" }
      tsquery = words.join(' & ')
      
      sanitized_query = connection.quote(tsquery)
      
      where("#{searchable_column} @@ to_tsquery('english', ?)", tsquery)
        .order(Arel.sql("ts_rank(#{searchable_column}, to_tsquery('english', #{sanitized_query})) DESC"))
    end
    
    # Legacy full-text search method (kept for backward compatibility)
    # @param query [String] search term
    # @param searchable_column [Symbol] column containing searchable text
    # @return [ActiveRecord::Relation] matching records ordered by relevance
    def full_text_search(query, searchable_column)
      sanitized_query = connection.quote(query)
      where("#{searchable_column} @@ plainto_tsquery('english', ?)", query)
        .order(Arel.sql("ts_rank(#{searchable_column}, plainto_tsquery('english', #{sanitized_query})) DESC"))
    end

    # Trigram similarity search using pg_trgm for partial word matching
    # @param query [String] search term
    # @param fields [Array<Symbol>] fields to search in
    # @return [ActiveRecord::Relation] matching records ordered by similarity
    def trigram_search(query, fields)
      begin
        # Use trigram similarity with a reasonable threshold (0.3 = 30% similarity)
        similarity_conditions = fields.map { |field| "similarity(#{field}, ?) > 0.3" }
        
        # Create ORDER BY clause with proper parameter substitution
        similarity_order_parts = fields.map { |field| "similarity(#{field}, '#{query.gsub("'", "''")}') DESC" }
        similarity_order = similarity_order_parts.join(', ')
        
        values_for_conditions = Array.new(fields.length, query)
        
        where(similarity_conditions.join(' OR '), *values_for_conditions)
          .order(Arel.sql(similarity_order))
      rescue => e
        # If trigram search fails (extension not available, etc.), fallback to ILIKE
        Rails.logger.warn "Trigram search failed: #{e.message}. Falling back to ILIKE search."
        ilike_search(query, fields)
      end
    end
    
    # ILIKE search across multiple fields
    # @param query [String] search term
    # @param fields [Array<Symbol>] fields to search in
    # @return [ActiveRecord::Relation] matching records ordered by first field
    def ilike_search(query, fields)
      conditions = fields.map { |field| "#{field} ILIKE ?" }
      values = Array.new(fields.length, "%#{query}%")
      
      where(conditions.join(' OR '), *values)
        .order(fields.first)
    end
  end
end
