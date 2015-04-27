#Add caching so that subsequent runs against the same content don't need to hit the FITS server, which is really slow.
require 'cfs_file'
require 'fileutils'

class CfsFile

  def get_fits_xml_with_caching
    cache_dir = File.join(Rails.root, 'tmp', 'fits_cache')
    FileUtils.mkdir_p(cache_dir)
    #Because of how some tests are structured we can't believe file.md5_sum here.
    md5 = Digest::MD5.file(self.absolute_path).to_s
    cache_file = File.join(cache_dir, md5)
    if File.exists?(cache_file)
      File.read(cache_file)
    else
      self.get_fits_xml_without_caching.tap do |fits|
        File.open(cache_file, 'w') {|f| f.write(fits)}
      end
    end
  end
  alias_method_chain :get_fits_xml, :caching

end