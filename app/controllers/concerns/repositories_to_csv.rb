require 'csv_generator'
module RepositoriesToCsv
  extend ActiveSupport::Concern

  def repositories_to_csv(repositories, csv_options = {})
    CsvGenerator.generate(repositories,
                          {id: 'Id', title: 'Title', contact_email: 'Contact', url: 'URL',
                           total_size: 'Total Size(GB)', notes: 'Notes'},
        csv_options)
  end
end