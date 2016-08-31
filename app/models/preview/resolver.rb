require 'singleton'

module Preview
  class Resolver < Object
    include Singleton

    attr_accessor :mime_type_viewers, :extension_viewers

    def initialize
      self.mime_type_viewers = invert_hash_of_arrays(Settings.cfs_file_viewers.mime_types)
      self.extension_viewers = invert_hash_of_arrays(Settings.cfs_file_viewers.extensions)
    end

    def find_preview_viewer_type(cfs_file)
      mime_type_viewers[cfs_file.content_type_name] ||
          extension_viewers[File.extname(cfs_file.name).sub(/^\./, '').downcase] ||
          :none
    end

    protected

    def invert_hash_of_arrays(hash_of_arrays)
      Hash.new.tap do |h|
        hash_of_arrays.each do |key, values|
          values.each { |value| h[value] = key.to_sym }
        end
      end
    end

  end
end