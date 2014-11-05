require 'csv_generator'
module CollectionsToCsv
  extend ActiveSupport::Concern

  def collections_to_csv(collections, csv_options = {})
    CsvGenerator.generate(collections, {:id => 'Id', :external_id => 'External Id', :uuid => 'UUID',
                                        :title => 'Title', :repository_title => 'Repository',
                                        :contact_email => 'Contact', :total_size => 'Total Size(GB)', :preservation_priority_name => 'Preservation Priority',
                                        :notes => 'Notes', :description => 'Description'},
                          csv_options)
  end

end