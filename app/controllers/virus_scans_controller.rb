class VirusScansController < ApplicationController

  def show
    @virus_scan = VirusScan.find(params[:id])
  end

end