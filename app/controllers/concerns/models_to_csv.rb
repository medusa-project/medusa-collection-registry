require 'csv_generator'

module ModelsToCsv
  extend ActiveSupport::Concern

  def models_to_csv(models, header_hash, csv_options = {})
    CsvGenerator.generate(models, header_hash, csv_options)
  end

  def collections_to_csv(collections, csv_options = {})
    models_to_csv(collections, {id: 'Id', external_id: 'External Id', uuid: 'UUID',
                                title: 'Title', repository_title: 'Repository',
                                contact_email: 'Contact', total_size: 'Total Size(GB)', preservation_priority_name: 'Preservation Priority',
                                notes: 'Notes', description: 'Description'}, csv_options)
  end

  def repositories_to_csv(repositories, csv_options = {})
    models_to_csv(repositories, {id: 'Id', title: 'Title', contact_email: 'Contact', url: 'URL',
                                 total_size: 'Total Size(GB)', notes: 'Notes'}, csv_options)
  end

  def projects_to_csv(projects, csv_options = {})
    models_to_csv(projects, {id: 'Id', title: 'Title', manager_email: 'Manager',
                             owner_email: 'Owner', start_date: 'Start Date', status: 'Status',
                             specifications: 'Specifications', summary: 'Summary'}, csv_options)
  end
end