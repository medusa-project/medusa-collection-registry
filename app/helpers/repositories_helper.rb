module RepositoriesHelper

  def repository_confirm_message
    'This is irreversible. Associated collections and their associated assessments and file groups will also be deleted.'
  end

  def repository_tab_list
    ['overview', 'running-processes', 'file-statistics', 'red-flags', ['combined-events-tab', 'Events', 'newspaper-o'], 'amazon', 'accruals']
  end

end
