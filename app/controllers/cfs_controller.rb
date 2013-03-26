class CfsController < ApplicationController

  def show
    @path = params[:path]
    file = cfs_file_path(@path)
    exists = File.exists?(file)
    unless exists
      render 'show_not_found' and return
    end
    if File.directory?(file)
      render 'show_directory'
    else
      render 'show_file'
    end
  end

  protected

  def cfs_file_path(url_path)
    File.join(MedusaRails3::Application.cfs_root, url_path)
  end

end