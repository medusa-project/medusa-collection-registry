module RightsDeclarationsHelper

  def copyright_jurisdiction_select_items
    hash_to_sorted_select_items(RightsDeclaration.all_copyright_jurisdictions, 'us')
  end

  def copyright_statement_select_items
    hash_to_sorted_select_items(RightsDeclaration.all_copyright_statements, 'pd')
  end

  def access_restriction_select_items
    hash_to_sorted_select_items(RightsDeclaration.all_access_restrictions, 'DISSEMINATE/DISALLOW')
  end

  memoize :copyright_jurisdiction_select_items, :copyright_statement_select_items, :access_restriction_select_items

  protected
  def hash_to_sorted_select_items(hash, default_key = nil)
    default_value = hash.delete(default_key) if default_key
    items = hash.collect do |k, v|
      [v, k]
    end.sort_by(&:first)
    items.unshift [default_value, default_key] if default_key
    items
  end

end