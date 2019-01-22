module AssessmentsHelper

  def storage_media_select_collection
    collection = StorageMedium.all.collect do |medium|
      [medium.name, medium.id]
    end
    [["<Leave blank>", ""]] + collection
  end

  def assessment_form_tab_list
    %w(assessment-metadata base directory-structure preservation-risks naming-conventions notes)
  end

  def new_assessment_path_for(assessable)
    new_assessment_path(assessable_id: assessable.id, assessable_type: assessable.class.name)
  end

end
