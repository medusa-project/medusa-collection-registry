require 'open3'
module Fits::Runner

  module_function

  def fits_binary_path
    Settings.fits.binary.tap do |path|
      raise RuntimeError, 'No fits binary configured' if path.blank?
    end
  end

  def fits_xml_for_cfs_file(cfs_file)
    cfs_file.with_input_file do |input_file|
      xml, status = Open3.capture2(fits_binary_path, '-i', input_file)
      raise RuntimeError, "Error running fits binary on cfs file id: #{cfs_file.id}" unless status.success?
      #remove any junk we get before the actual FITS
      if index = xml.index('<?xml')
        xml.slice!(0, index)
      end
      return xml
    end
  end

  def update_cfs_file(cfs_file)
    cfs_file.fits_xml = fits_xml_for_cfs_file(cfs_file)
  end

end