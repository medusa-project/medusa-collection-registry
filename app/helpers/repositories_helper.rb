module RepositoriesHelper

  def repository_confirm_message
    'This is irreversible. Associated collections and their associated assessments and file groups will also be deleted.'
  end

  def repository_tab_list
    %w(overview running-processes)
  end

end
