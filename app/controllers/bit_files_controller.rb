require 'fileutils'

class BitFilesController < ApplicationController

  skip_before_filter :require_logged_in, :only => :show
  skip_before_filter :authorize, :only => :show
  before_filter :get_bit_file

  def show
    respond_to do |format|
      format.json
    end
  end

  def contents
    file = Tempfile.new(@bit_file.name, MedusaRails3::Application.bit_file_tmp_dir, :encoding => 'binary')
    file.chmod(0644)
    Dx.instance.export_file_2(@bit_file, file)
    file.close
    send_file file.path, :type => @bit_file.content_type, :filename => @bit_file.name, :disposition => 'inline'
  end

  protected

  def get_bit_file
    @bit_file = BitFile.find(params[:id])
  end

end