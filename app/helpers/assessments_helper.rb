module AssessmentsHelper

  def storage_media_select_collection
    StorageMedium.all.collect do |medium|
      [medium.name, medium.id]
    end
  end

  def assessment_form_tab_list
    %w(assessment-metadata base directory-structure preservation-risks naming-conventions notes)
  end

  def link_to_assessable(assessable)
    case assessable
      when FileGroup
        link_to("Back to File group", file_group_path(@assessable), :class => 'btn')
      else
        link_to("Back to #{@assessable.class.name}", @assessable, :class => 'btn')
    end
  end

end
