require 'nokogiri'

module BookTracker

  ##
  # Recursively scans a given directory for MARCXML records to import, and
  # imports them.
  #
  class Filesystem

    def self.import_in_progress?
      Task.where(service: Service::LOCAL_STORAGE).
          where('status NOT IN (?)', [Status::SUCCEEDED, Status::FAILED]).
          limit(1).any?
    end

    ##
    # Imports records from a tree of MARCXML files, updating them if one with
    # the same bib ID already exists, and adding them if not.
    #
    def import
      if Filesystem.import_in_progress? or Service.check_in_progress?
        raise 'Cannot import while another import or service check is in '\
        'progress.'
      end

      task = Task.create!(name: 'Getting record count',
                          service: Service::LOCAL_STORAGE)
      puts task.name

      begin
        path = MedusaRails3::Application.medusa_config['book_tracker']['import_path']
        path = File.expand_path(path.chomp('/'))
        raise "Import path (#{path}) does not exist." unless Dir.exist?(path)

        num_inserted = 0
        num_updated = 0
        num_missing_bib_ids = 0
        num_invalid_files = 0
        record_index = 0
        num_records = record_count(path)

        task.name = "Importing #{num_records} MARCXML records"
        task.save!

        # Find all XML files in or beneath self.path
        files = Dir.glob(path + '/**/*.xml').select{ |file| File.file?(file) }
        files.each do |file|
          File.open(file) do |contents|
            begin
              doc = Nokogiri::XML(contents, &:noblanks)
              doc.encoding = 'utf-8'
              namespaces = { 'marc' => 'http://www.loc.gov/MARC21/slim' }

              doc.xpath('//marc:record', namespaces).each do |record|
                begin
                  item, status = Item.insert_or_update!(
                      Item.params_from_marcxml_record(record))
                  if status == Item::INSERTED
                    num_inserted += 1
                  else
                    num_updated += 1
                  end
                rescue => e
                  num_missing_bib_ids += 1 if e.message.include?('Bib can\'t be blank')
                  puts "#{file}: #{e}"
                end
                record_index += 1
                if record_index % 1000 == 0
                  task.percent_complete = record_index.to_f / num_records.to_f
                  task.save!
                end
              end
            rescue => e
              # This is probably an undefined namespace prefix error, which
              # means it's either an invalid MARCXML file or, more likely, a
              # non-MARCXML XML file, which is not an issue.
              num_invalid_files += 1
              puts "#{file}: #{e}"
            end
          end
        end
      rescue SystemExit, Interrupt => e
        task.name = "Import failed: #{e}"
        task.status = Status::FAILED
        task.save!
        puts task.name
        raise e
      rescue => e
        task.name = "Import failed: #{e}"
        task.status = Status::FAILED
        task.save!
        puts task.name
      else
        task.name += ": #{num_inserted} records added; #{num_updated} "\
        "records updated or unchanged; #{num_missing_bib_ids} missing bib IDs "\
        "and not imported; #{num_invalid_files} skipped XML files"
        task.status = Status::SUCCEEDED
        task.save!
        puts task.name
      end
    end

    private

    def record_count(path)
      count = 0
      Dir.glob(File.expand_path(path.chomp('/')) + '/**/*.xml').each do |file|
        File.open(file) do |contents|
          doc = Nokogiri::XML(contents, &:noblanks)
          namespaces = { 'marc' => 'http://www.loc.gov/MARC21/slim' }
          begin
            count += doc.xpath('//marc:record', namespaces).length
          rescue
          end
        end
      end
      count
    end

  end

end
