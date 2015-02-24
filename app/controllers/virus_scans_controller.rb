class VirusScansController < ApplicationController

  before_action :require_logged_in

  def show
    @virus_scan = VirusScan.find(params[:id])
    @file_group = @virus_scan.file_group
    @collection = @file_group.collection
  end

end