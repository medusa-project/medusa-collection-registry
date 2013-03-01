module FileGroupsHelper

  def producers_select_collection
    Producer.order(:title).all.collect do |producer|
      [producer.title, producer.id]
    end
  end

  def potential_related_file_group_collection(file_group)
    file_group.sibling_file_groups.collect do |sibling|
      [sibling.name, sibling.id]
    end
  end

  def file_types_select_collection
    FileType.order(:name).all.collect do |type|
      [type.name, type.id]
    end
  end

  def file_group_form_tab_list
    ['base', 'rights-declaration', 'summary', 'provenance-note',
     'collection-file-package-summary', 'related-file-groups']
  end

end
