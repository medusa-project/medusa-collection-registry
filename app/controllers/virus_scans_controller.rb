class VirusScansController < ApplicationController

  before_action :require_medusa_user

  def show
    @virus_scan = VirusScan.find(params[:id])
    @file_group = @virus_scan.file_group
    @collection = @file_group.collection
  end

end