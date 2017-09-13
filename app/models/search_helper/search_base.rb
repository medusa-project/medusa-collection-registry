class SearchHelper::SearchBase < SearchHelper::Base

  def table_id
    "search_#{base_plural_name}"
  end

  def tab_id
    "tab_#{base_plural_name}"
  end

  def tab_label
    base_plural_name.humanize
  end

  def url
    "/searches/#{base_name}.json"
  end

  def full_count
    if base_class.respond_to?(:search)
      base_class.search{ keywords ''}.total
    else
      base_class.count
    end
  end

  def search
    @search ||= base_class.search do
      fulltext search_string, fields: search_fields
      paginate page: page, per_page: per_page
      order_by order_field, order_direction if order_field and order_direction
    end
  end

end