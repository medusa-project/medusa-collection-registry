module LogicalExtensionsHelper

  def logical_extensions_select_collection
    [['<Leave blank>', '']] + LogicalExtension.order(:extension, :description).collect {|le| [le.label, le.id]}
  end

end