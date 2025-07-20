module ProductFilterable
  extend ActiveSupport::Concern

  private

  def apply_search(products, search_query)
    return products unless search_query.present?

    products.search_in_name_and_desc(search_query)
  end

  def apply_filters(products, filter_params)
    filtered_products = products

    # Stock filter
    if filter_params[:in_stock] == "true"
      filtered_products = filtered_products.where("stock > 0")
    end

    # Price range filters
    if filter_params[:min_price].present?
      filtered_products = filtered_products.where("price >= ?", filter_params[:min_price])
    end

    if filter_params[:max_price].present?
      filtered_products = filtered_products.where("price <= ?", filter_params[:max_price])
    end

    filtered_products
  end

  def apply_sorting(products, sort_by)
    case sort_by
    when "price_asc"
      products.order(price: :asc)
    when "price_desc"
      products.order(price: :desc)
    when "name"
      products.order(name: :asc)
    when "newest"
      products.order(created_at: :desc)
    else
      products.order(:name)
    end
  end

  def apply_pagination(products, limit: nil, offset: nil)
    products.limit(limit || 20).offset(offset || 0)
  end

  def filter_and_sort_products(base_products = Product.all, params = {})
    products = base_products

    # Apply search
    products = apply_search(products, params[:search])

    # Apply filters
    filter_params = params.slice(:in_stock, :min_price, :max_price)
    products = apply_filters(products, filter_params)

    # Apply sorting
    products = apply_sorting(products, params[:sort_by])

    # Apply pagination
    products = apply_pagination(products, limit: params[:limit], offset: params[:offset])

    products
  end

  def get_filtered_products_with_metadata(params = {})
    # Get base products with eager loading to prevent N+1 queries
    base_products = Product.includes(:order_items)
    base_products = apply_search(base_products, params[:search])

    filter_params = params.slice(:in_stock, :min_price, :max_price)
    base_products = apply_filters(base_products, filter_params)
    base_products = apply_sorting(base_products, params[:sort_by])

    # Get the filtered count before pagination
    filtered_count = base_products.count

    # Apply pagination
    paginated_products = apply_pagination(base_products, limit: params[:limit], offset: params[:offset])

    {
      products: paginated_products.as_json(include: [ :order_items ]),
      total_count: Product.count,
      filtered_count: filtered_count
    }
  end
end
