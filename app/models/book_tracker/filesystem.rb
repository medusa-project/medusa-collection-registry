require 'nokogiri'

module BookTracker

  ##
  # Recursively scans a given directory (set in
  # Application.config.fs_importer_path) for MARCXML records to import, and
  # imports them.
  #
  # Run the importer from the command line with: rake mbt:fs_import
  #
  class Filesystem

    attr_accessor :path

    def self.import_in_progress?
      Task.where('name LIKE \'Import%\'').
          where('status NOT IN (?)', [Status::SUCCEEDED, Status::FAILED]).
          limit(1).any?
    end

    def initialize
      self.path = MedusaRails3::Application.medusa_config['book_tracker']['import_path']
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

      task = Task.create!(name: 'Importing MARCXML records')
      puts task.name

      begin
        num_inserted = 0
        num_updated = 0

        # Find all XML files in or beneath self.path
        files = Dir.glob(File.expand_path(path.chomp('/')) + '/**/*.xml').
            select{ |file| File.file?(file) }
        files.each_with_index do |file, index|
          fh = File.open(file)
          doc = Nokogiri::XML(fh, &:noblanks)

          doc.xpath('//xmlns:collection/xmlns:record').each do |record|
            item, status = Item.insert_or_update!(
                item_params_from_marcxml_record(record))
            if status == Item::INSERTED
              num_inserted += 1
            else
              num_updated += 1
            end
          end

          fh.close

          task.percent_complete = (index + 1).to_f / files.length.to_f
          task.save!
        end
      rescue Interrupt => e
        task.name = 'Filesystem import aborted'
        task.status = Status::FAILED
        task.save!
        raise e
      rescue => e
        task.name = "Filesystem import failed: #{e}"
        task.status = Status::FAILED
        task.save!
        raise e
      else
        task.name += ": #{num_inserted} records inserted; #{num_updated} "\
        "records updated or unchanged"
        task.status = Status::SUCCEEDED
        task.save!
        puts task.name
      end
    end

    private

    ##
    # @param record Nokogiri element corresponding to a /collection/record
    # element in a MARCXML file
    # @return Params hash for an Item
    #
    def item_params_from_marcxml_record(record)
      item_params = { bib_id: nil, oclc_number: nil, obj_id: nil, title: nil,
                      author: nil, volume: nil, date: nil, raw_marcxml: nil }

      # raw MARCML
      item_params[:raw_marcxml] = record.to_xml(indent: 2)

      # extract bib ID
      nodes = record.xpath('xmlns:controlfield[@tag = 001][1]')
      item_params[:bib_id] = nodes[0].content.strip if nodes.any?

      # extract OCLC no. from 035 subfield a
      nodes = record.
          xpath('xmlns:datafield[@tag = 035][1]/xmlns:subfield[@code = \'a\'][1]')
      item_params[:oclc_number] = nodes[0].content.sub(/^[(OCoLC)]*/, '').strip if
          nodes.any?

      # extract author & title from 100 & 245
      item_params[:author] = record.
          xpath('xmlns:datafield[@tag = 100][1]/xmlns:subfield[1]').
          map{ |t| t.content }.join(' ').strip
      item_params[:title] = record.
          xpath('xmlns:datafield[@tag = 245][1]/xmlns:subfield[1]').
          map{ |t| t.content }.join(' ').strip

      # extract volume from 955 subfield v
      nodes = record.
          xpath('xmlns:datafield[@tag = 955][1]/xmlns:subfield[@code = \'v\'][1]')
      item_params[:volume] = nodes[0].content.strip if nodes.any?

      # extract date from 260 subfield c
      nodes = record.
          xpath('xmlns:datafield[@tag = 260][1]/xmlns:subfield[@code = \'c\'][1]')
      item_params[:date] = nodes[0].content.strip if nodes.any?

      # extract object ID from 955 subfield b
      # For Google digitized volumes, this will be the barcode.
      # For Internet Archive digitized volumes, this will be the Ark ID.
      # For locally digitized volumes, this will be the bib ID (and other extensions)
      nodes = record.
          xpath('xmlns:datafield[@tag = 955]/xmlns:subfield[@code = \'b\'][1]')
      item_params[:obj_id] = nodes[0].content.strip if nodes.any?

      # extract IA identifier from 955 subfield q
      nodes = record.
          xpath('xmlns:datafield[@tag = 955]/xmlns:subfield[@code = \'q\'][1]')
      item_params[:ia_identifier] = nodes[0].content.strip if nodes.any?

      item_params
    end

  end

end
