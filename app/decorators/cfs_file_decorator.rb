class CfsFileDecorator < BaseDecorator

  def label
    object.relative_path
  end

  def cfs_label
    object.relative_path
  end

  def cfs_type
    'CFS File'
  end

  def fits_button
    if fits_xml
      h.small_view_button(h.fits_cfs_file_path(self, format: :xml))
    else
      h.small_create_button(h.create_fits_xml_cfs_file_path(self, method: :post))
    end
  end

end