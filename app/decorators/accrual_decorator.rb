class AccrualDecorator < BaseDecorator

  def parent_display_path
    h.update_display_accrual_path(cfs_directory_id: cfs_directory_id, staging_path: path_up)
  end

  def child_display_path(child_name)
    h.update_display_accrual_path(cfs_directory_id: cfs_directory_id, staging_path: path_down(child_name))
  end

  #This is a dummy method used to make the checkboxes
  def accrual_directories
    nil
  end

  #This is a dummy method used to make the checkboxes
  def accrual_files
    nil
  end

  #This is a dummy method to streamline simple form
  def allow_overwrite
    false
  end

  def file_checkboxes
    h.content_tag(:div, class: 'accrual-list list-group') do
      h.collection_check_boxes(:accrual, :accrual_files, self.files, :itself, :itself) do |box|
        h.content_tag(:div, class: 'list-group-item') do
          box.label do
            box.check_box(class: 'accrual_file') + " " + box.text
          end
        end
      end
    end
    # h.content_tag(:ul, class: 'accrual-list list-group') do
    #   h.collection_check_boxes(:accrual, :accrual_files, self.files, :itself, :itself) do |box|
    #     h.content_tag(:li, class: 'list-group-item') do
    #       box.label do
    #         box.check_box(class: 'accrual_file') + " " + box.text
    #       end
    #     end
    #   end
    # end
  end

  def directory_checkboxes
    h.content_tag(:div, class: 'accrual-list list-group') do
      h.collection_check_boxes(:accrual, :accrual_directories, directories, :itself, Proc.new { |directory| h.link_to(directory, child_display_path(directory), remote: true) }) do |box|
        h.content_tag(:div, class: 'list-group-item') do
          box.label do
            box.check_box(class: 'accrual_directory') + " " + box.text
          end
        end
      end
    end

  end

end