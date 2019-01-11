module FileGroupsHelper

  def producers_select_collection
    Producer.order(:title).load.collect do |producer|
      [producer.title, producer.id]
    end
  end

  def file_group_form_tab_list
    %w(descriptive-metadata administrative-metadata)
  end

  def acquisition_methods_collection
    [['<Leave blank>', '']] + FileGroup.acquisition_methods.zip(FileGroup.acquisition_methods)
  end

end
