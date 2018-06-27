#Add caching so that subsequent runs against the same content don't need to hit the FITS server, which is really slow.
require 'cfs_file'
require 'fileutils'

module AddFitsCachingToCfsFile
  def get_fits_xml
    cache_dir = File.join(Rails.root, 'tmp', 'fits_cache')
    FileUtils.mkdir_p(cache_dir)
    #Because of how some tests are structured we can't believe file.md5_sum here.
    md5 = cfs_file.storage_md5_sum
    cache_file = File.join(cache_dir, md5)
    if File.exists?(cache_file)
      File.read(cache_file)
    else
      super.tap do |fits|
        File.open(cache_file, 'w') {|f| f.write(fits)}
      end
    end
  end
end

class CfsFile
  Module.prepend(AddFitsCachingToCfsFile)
end