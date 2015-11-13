class ItemDecorator < BaseDecorator

  def search_barcode_link
    h.link_to(self.barcode, h.item_path(self))
  end

  def search_project_link
    h.link_to(self.project_title, h.project_path(self.project))
  end

end