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
    models_to_csv(projects, {id: 'Id', external_id: 'External id', title: 'Title', manager_email: 'Manager',
                             owner_email: 'Owner', start_date: 'Start Date', status: 'Status',
                             specifications: 'Specifications', summary: 'Summary'}, csv_options)
  end

  def items_to_csv(items, csv_options = {})
    models_to_csv(items, {barcode: 'Barcode', local_title: 'Local Title', local_description: 'Local Description',
                          notes: 'Notes', batch: 'Batch', file_count: 'File Count', status: 'Status',
                          reformatting_date: 'Reformatting Date', reformatting_operator: 'Reformatting Operator',
                          equipment: 'Equipment', foldout_present: 'Foldout Present', unique_identifier: 'Unique Identifier',
                          call_number: 'Call Number', title: 'Title', author: 'Author', imprint: 'Imprint', bib_id: 'BibId', oclc_number: 'OCLC number',
                          record_series_id: 'Record Series Id', archival_management_system_url: 'Archival Management System URL',
                          series: 'Series', sub_series: 'Sub-series', box: 'Box', folder: 'Folder', item_title: 'Item Title'})
  end

  def file_format_tests_to_csv(file_format_tests, csv_options = {})
    fields = {profile_name: 'FileFormatProfile', profile_name_simplified: 'FileFormatProfileSimplified',
              cfs_file_name: 'File name', medusa_url: 'Medusa Url', tester_email: 'Tester email', date: 'Test date',
              content_type_name: 'File type', pass_label: 'Status', reasons_string: 'Reasons',
              notes: 'Comments', file_group_id: 'File group Id', file_group_title: 'File group title',
              acquisition_method: 'Acquistion method',
              collection_id: 'Collection Id', collection_title: 'Collection title',
              repository_id: 'Repository Id', repository_title: 'Repository title'}
    FitsData::ALL_FIELDS.each do |field|
      fields[:"fits_data_#{field}"] = field.to_s.titlecase
    end
    models_to_csv(file_format_tests, fields, csv_options)
  end

  def file_stats_to_csv(content_type_hashes, file_extension_hashes)
    CSV.generate do |csv|
      csv << ['File Format', 'Number of Files', 'Number Tested', 'Percentage Tested', 'Size']
      content_type_hashes.each do |info|
        csv << [info['name'], info['file_count'].to_i, info['tested_count'].to_i, (100 * info['tested_count'].to_d / info['file_count'].to_d), info['file_size']]
      end
      csv << []
      csv << ['File Extension', 'Number of Files', 'Number Tested', 'Percentage Tested', 'Size']
      file_extension_hashes.each do |info|
        csv << [info['extension'], info['file_count'].to_i, info['tested_count'].to_i, (100 * info['tested_count'].to_d / info['file_count'].to_d), info['file_size']]
      end
    end
  end

end