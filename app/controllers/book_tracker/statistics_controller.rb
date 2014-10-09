module BookTracker

  class StatisticsController < ApplicationController

    def index
      @num_items = Item.count

      @num_items_in_ht = Item.where(exists_in_hathitrust: true).count
      @num_items_in_ia = Item.where(exists_in_internet_archive: true).count
      @num_items_in_ia = Item.where(exists_in_google: true).count
      @num_items_not_in_ht = @num_items - @num_items_in_ht
      @num_items_not_in_ia = @num_items - @num_items_in_ia
      @num_items_not_in_gb = @num_items - @num_items_in_gb

      @num_ht_items_not_in_ia = Item.where(exists_in_hathitrust: true).
          where(exists_in_internet_archive: false).count
      @num_ht_items_not_in_gb = Item.where(exists_in_hathitrust: true).
          where(exists_in_google: false).count

      @num_ia_items_not_in_ht = Item.where(exists_in_hathitrust: false).
          where(exists_in_internet_archive: true).count
      @num_ia_items_not_in_gb = Item.where(exists_in_google: false).
          where(exists_in_internet_archive: true).count

      @num_gb_items_not_in_ht = Item.where(exists_in_google: true).
          where(exists_in_hathitrust: false).count
      @num_gb_items_not_in_ia = Item.where(exists_in_google: true).
          where(exists_in_internet_archive: false).count

      @import_path = MedusaRails3::Application.medusa_config['book_tracker']['import_path']
    end

  end

end
