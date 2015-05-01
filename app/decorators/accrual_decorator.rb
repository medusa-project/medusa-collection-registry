class AccrualDecorator < BaseDecorator

  def parent_display_path
    h.update_display_accrual_path(cfs_directory_id: cfs_directory_id, staging_path: path_up)
  end

  def child_display_path(child_name)
    h.update_display_accrual_path(cfs_directory_id: cfs_directory_id, staging_path: path_down(child_name))
  end

  def accrual_directories
    nil
  end

  def accrual_files
    nil
  end

end