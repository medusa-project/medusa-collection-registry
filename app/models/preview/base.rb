module Preview
  class Base < Object
    attr_accessor :cfs_file

    def initialize(cfs_file)
      self.cfs_file = cfs_file
    end

  end
end