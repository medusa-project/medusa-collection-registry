class DashboardController < ApplicationController
  def show
    setup_storage
    setup_external_storage
  end

  protected

  def setup_storage
    @storage = Hash.new
    @storage["bit_level_ingested"] = BitFile.where(:dx_ingested => true).sum(:size)/1000
    @storage["bit_level_total"] = BitFile.sum(:size)/1000
    @storage["object_level_total"] = 0
    @storage["total"] = 4000
    @storage["free"] = @storage["total"] - @storage["bit_level_total"] - @storage["object_level_total"]
  end

  #TODO - I bet we can do this more efficiently - it'd be easy with SQL, but we can probably do it with arel as well.
  def setup_external_storage
    @external_storage_summary = []
    Repository.includes(:collections => :file_groups).all.each do |repository|
      file_groups = repository.collections.collect{|c| c.file_groups.select {|fg| fg.is_a?(ExternalFileGroup)}}.flatten
      @external_storage_summary << Hash.new.tap do |h|
        h[:repository] = repository
        h[:file_count] = file_groups.collect{|fg| fg.total_files || 0}.sum
        h[:size] = file_groups.collect {|fg| fg.total_file_size || 0}.sum
      end
    end
    @external_storage_summary.sort! {|a, b| b[:size] <=> a[:size]}
  end
end