class AddSearchableToProducts < ActiveRecord::Migration[8.0]
  def up
    # Enable necessary extensions
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')
    enable_extension 'unaccent' unless extension_enabled?('unaccent')

    # Add searchable column
    add_column :products, :searchable, :tsvector

    # Create a function to update the searchable column
    execute <<-SQL
      CREATE OR REPLACE FUNCTION products_search_trigger() RETURNS trigger AS $$
      begin
        new.searchable :=
          setweight(to_tsvector('english', coalesce(new.name, '')), 'A') ||
          setweight(to_tsvector('english', coalesce(new.description, '')), 'B');
        return new;
      end
      $$ LANGUAGE plpgsql;
    SQL

    # Create a trigger to update the searchable column
    execute <<-SQL
      CREATE TRIGGER tsvector_update_products
      BEFORE INSERT OR UPDATE ON products
      FOR EACH ROW EXECUTE FUNCTION products_search_trigger();
    SQL

    # Update existing records
    Product.find_each(&:touch)

    # Create GIN index for the searchable column
    add_index :products, :searchable, using: :gin, name: 'gin_idx_products_on_searchable'
  end

  def down
    remove_index :products, name: 'gin_idx_products_on_searchable'
    execute 'DROP TRIGGER IF EXISTS tsvector_update_products ON products'
    execute 'DROP FUNCTION IF EXISTS products_search_trigger()'
    remove_column :products, :searchable
  end
end
