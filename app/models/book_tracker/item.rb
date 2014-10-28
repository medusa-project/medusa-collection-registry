module BookTracker

  class Item < ActiveRecord::Base

    # Used by self.insert_or_update!
    INSERTED = 0
    # Used by self.insert_or_update!
    UPDATED = 1

    validates :bib_id, presence: true, length: { maximum: 255 } # TODO: what is the max length of a bib ID?

    before_save :truncate_values

    ##
    # Static method that either inserts a new item, or updates an existing item,
    # depending on whether an item with a matching bib ID is already present in
    # the database.
    #
    # @return Array with the created or updated Item at position 0 and the status
    # (Item::INSERTED or Item::UPDATED) at position 1
    #
    def self.insert_or_update!(params)
      status = Item::UPDATED
      item = Item.find_by_bib_id(params[:bib_id])
      if item
        item.update_attributes(params)
      else
        item = Item.new(params)
        status = Item::INSERTED
      end
      item.save!
      return item, status
    end

    def self.to_csv(options = {})
      headings = ['Medusa ID'] + ['Bib ID'] + ['OCLC Number'] + ['Object ID'] +
          ['Title'] + ['Author'] + ['Volume'] + ['Date'] + ['IA Identifier'] +
          ['Exists in HathiTrust'] + ['Exists in IA'] + ['Exists in Google']
      columns = ['id'] + ['bib_id'] + ['oclc_number'] + ['obj_id'] + ['title'] +
          ['author'] + ['volume'] + ['date'] + ['ia_identifier'] +
          ['exists_in_hathitrust'] + ['exists_in_internet_archive'] +
          ['exists_in_google']
      CSV.generate(options) do |csv|
        csv << headings
        all.each do |item|
          csv << item.attributes.values_at(*columns)
        end
      end
    end

    ##
    # It is not possible to generate a link directly to a Google item, as
    # Google Books URLs use private IDs. Instead, this method returns a URL
    # of a search for the item.
    #
    # @return string
    #
    def google_url
      disallowed_characters = '`~!@#$%^&*()_\+\-=[]{}|\\\"\'<>,.?/:;'
      sanitized_title = self.title.tr(disallowed_characters, '')
      sanitized_author = self.author.tr(disallowed_characters, '')
      q = []
      q << 'intitle:' + sanitized_title.split(' ').select{ |t| t.length > 1 }.
          join(' intitle:') unless sanitized_title.blank?
      q << 'inauthor:' + sanitized_author.split(' ').select{ |t| t.length > 1 }.
          join(' inauthor:') unless sanitized_author.blank?
      "https://www.google.com/search?tbo=p&tbm=bks&q=#{q.join('+')}&num=10&gws_rd=ssl"
    end

    ##
    # Returns the expected HathiTrust handle of the item. The handle should
    # work if self.exists_in_hathitrust is true; otherwise it will be broken.
    #
    # @return string
    #
    def hathitrust_handle
      case self.service
        when Service::INTERNET_ARCHIVE
          "http://hdl.handle.net/2027/uiuo.#{self.obj_id}"
        when Service::GOOGLE
          "http://hdl.handle.net/2027/uiug.#{self.obj_id}"
        else # digitized locally or by vendors
          "http://hdl.handle.net/2027/uiuc.#{self.obj_id}"
      end
    end

    ##
    # Returns the expected Internet Archive URL of the item. If the item does not
    # exist in Internet Archive, the URL will be broken. The URL should work if
    # if self.exists_in_internet_archive is true.
    #
    # @return string
    #
    def internet_archive_url
      "https://archive.org/details/#{self.ia_identifier}"
    end

    def service
      if self.obj_id.start_with?('ark:/')
        Service::INTERNET_ARCHIVE
      elsif self.obj_id.length == 14 and self.obj_id[0] == '3'
        # It's a Google record if the object ID is a barcode. Barcodes are 14
        # digits and start with number 3.
        Service::GOOGLE
      end
    end

    def uiuc_catalog_url
      "http://vufind.carli.illinois.edu/vf-uiu/Record/uiu_#{self.bib_id}"
    end

    private

    def truncate_values
      self.author = self.author[0..254] if self.author and self.author.length > 255
      self.date = self.date[0..254] if self.date and self.date.length > 255
      self.title = self.title[0..254] if self.title and self.title.length > 255
      self.volume = self.volume[0..254] if self.volume and self.volume.length > 255
    end

  end

end
