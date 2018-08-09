module FileGroupsHelper

  def producers_select_collection
    Producer.order(:title).load.collect do |producer|
      [producer.title, producer.id]
    end
  end

  def file_group_form_tab_list
    %w(descriptive-metadata administrative-metadata rights-metadata)
  end

  def package_profile_select_collection
    PackageProfile.order('name ASC').load.collect {|profile| [profile.name, profile.id]}
  end

end
