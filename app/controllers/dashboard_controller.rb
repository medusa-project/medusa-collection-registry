class DashboardController < ApplicationController
  def show
  	@storage = Hash.new
  	@storage["bit_level_ingested"] = BitFile.where(:dx_ingested => true).sum(:size )/1000
  	@storage["bit_level_total"] = BitFile.sum(:size )/1000
  	@storage["object_level_total"] = 0
  	@storage["total"] = 4000
  	@storage["free"] = @storage["total"] - @storage["bit_level_total"] - @storage["object_level_total"]
  end
end