module LogicalExtensionsHelper

  def logical_extensions_select_collection
    [['<Leave blank>', '']] + LogicalExtension.order(:extension, :description).collect {|le| [le.label, le.id]}
  end

  def logical_extension_groups(group_count: 3)
    LogicalExtension.order(:extension, :description).all.in_groups(group_count, false)
  end

end