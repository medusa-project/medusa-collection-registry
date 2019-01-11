module RightsDeclarationsHelper

  def copyright_jurisdiction_select_items
    hash_to_sorted_select_items(RightsDeclaration.copyright_jurisdictions, RightsDeclaration.default_copyright_jurisdiction)
  end

  def copyright_statement_select_items
    items = hash_to_sorted_select_items(RightsDeclaration.copyright_statements, RightsDeclaration.default_copyright_statement)
    #Move custom label to the end
    items = items.reject {|i| i.last == RightsDeclaration.custom_copyright_key} + items.select {|i| i.last == RightsDeclaration.custom_copyright_key}
    [["<Leave blank>", ""]] + items
  end

  def access_restriction_select_items
    hash_to_sorted_select_items(RightsDeclaration.access_restrictions, RightsDeclaration.default_access_restrictions)
  end

  protected

  def hash_to_sorted_select_items(hash, default_key = nil)
    hash = hash.clone
    default_value = hash.delete(default_key) if default_key
    items = hash.invert.sort
    items.unshift [default_value, default_key] if default_key
    items
  end

end