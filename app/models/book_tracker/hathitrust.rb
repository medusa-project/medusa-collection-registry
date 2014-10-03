require 'nokogiri'

module BookTracker

  ##
  # Checks HathiTrust for bibliographic data and updates the corresponding local
  # items with its findings.
  #
  class Hathitrust < Service

    def self.check_in_progress?
      Task.where(service: Service::HATHITRUST).
          where('status NOT IN (?)', [Status::SUCCEEDED, Status::FAILED]).
          limit(1).any?
    end

    ##
    # Checks HathiTrust by downloading the latest HathiFile
    # (http://www.hathitrust.org/hathifiles).
    #
    def check
      if Filesystem.import_in_progress? or Service.check_in_progress?
        raise 'Cannot check HathiTrust while another import or service check is '\
        'in progress.'
      end

      task = Task.create!(name: 'Checking HathiTrust',
                          service: Service::HATHITRUST)

      begin
        pathname = get_hathifile(task)

        nuc_code = MedusaRails3::Application.medusa_config['book_tracker']['library_nuc_code']

        task.name = "Scanning the HathiFile for #{nuc_code} records..."
        task.save!
        puts task.name

        num_lines = File.foreach(pathname).count

        items_in_hathitrust = 0

        # http://www.hathitrust.org/hathifiles_description
        File.open(pathname, 'rt').each_with_index do |line, index|
          parts = line.split("\t")
          if parts[5] == nuc_code
            item = Item.find_by_bib_id(parts[6])
            if item
              items_in_hathitrust += 1
              if !item.exists_in_hathitrust
                item.exists_in_hathitrust = true
                item.save!
              end
            end
          end

          if index % 50000 == 0
            task.percent_complete = (index + 1).to_f / num_lines.to_f
            task.save!
          end
        end
      rescue Interrupt => e
        task.name = 'HathiTrust check aborted'
        task.status = Status::FAILED
        task.save!
        raise e
      rescue => e
        task.name = "HathiTrust check failed: #{e}"
        task.status = Status::FAILED
        task.save!
        raise e
      else
        task.name += ": Updated database with #{items_in_hathitrust} found items."
        task.status = Status::SUCCEEDED
        task.save!
        puts task.name
      end
    end

    ##
    # Downloads the latest HathiFile into the cache folder.
    #
    # @param task The active Task
    # @return The path of the HathiFile.
    #
    def get_hathifile(task)
      # As there is no single URI for the latest HathiFile, we have to scrape
      # the HathiFile listing out of the index HTML page.
      task.name = 'Getting HathiFile index...'
      task.save!
      puts task.name

      uri = URI.parse('http://www.hathitrust.org/hathifiles')
      response = Net::HTTP.get_response(uri)
      page = Nokogiri::HTML(response.body)

      # Scrape the URI of the latest HathiFile out of the index
      node = page.css('table#filebrowser-file-listing td a').
          select{ |h| h.text.start_with?('hathi_full_') }.
          sort{ |x,y| x.text <=> y.text }.reverse[0]
      uri = node['href']
      gz_filename = node.text
      txt_filename = gz_filename.chomp('.gz')
      cache_pathname = Rails.root.join('public', 'system', 'book_tracker')
      gz_pathname = File.join(cache_pathname, gz_filename)
      txt_pathname = File.join(cache_pathname, txt_filename)

      # If we already have it, return its pathname instead of downloading it.
      return txt_pathname if File.exists?(txt_pathname)

      # Otherwise, delete any older HathiFiles that may exist, as they are now
      # out-of-date
      Dir.glob(File.join(cache_pathname, 'hathi_full_*.txt')).
          each { |f| File.delete(f) }

      # And progressively download the new one (because it's big)
      task.name = "Downloading the latest HathiFile (#{gz_filename})..."
      task.save!
      puts task.name

      FileUtils::mkdir_p(cache_pathname)
      Net::HTTP.get_response(URI.parse(uri)) do |res|
        res.read_body do |chunk|
          File.open(gz_pathname, 'ab') { |file|
            file.write(chunk)
          }
        end
      end

      task.name = "Unzipping #{gz_filename}..."
      task.save!
      puts task.name
      `gunzip #{gz_pathname}`

      txt_pathname
    end

  end

end