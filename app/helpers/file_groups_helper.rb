module FileGroupsHelper

  def producers_select_collection
    Producer.order(:title).load.collect do |producer|
      [producer.title, producer.id]
    end
  end

  def file_types_select_collection
    FileType.order(:name).load.collect do |type|
      [type.name, type.id]
    end
  end

  def file_group_form_tab_list
    ['essential-information', 'rights-declaration', 'summary', 'provenance-note',
     'collection-file-package-summary', 'related-file-groups']
  end

  def file_group_show_tab_list
    ['description', 'rights', 'assessments', 'attachments'].collect {|x| ["#{x}-tab", x.capitalize]}
  end

  def package_profile_select_collection
    PackageProfile.order('name ASC').load.collect {|profile| [profile.name, profile.id]}
  end

end
