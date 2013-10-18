require 'fileutils'

class BitFilesController < ApplicationController

  skip_before_filter :require_logged_in, :only => :show
  skip_before_filter :authorize, :only => :show
  before_filter :get_bit_file

  def show
    respond_to do |format|
      format.json {render json: show_json(@bit_file)}
    end
  end

  def contents
    file = Tempfile.new(@bit_file.name, MedusaRails3::Application.bit_file_tmp_dir, :encoding => 'binary')
    file.chmod(0644)
    Dx.instance.export_file_2(@bit_file, file)
    file.close
    send_file file.path, :type => @bit_file.content_type, :filename => @bit_file.name, :disposition => 'inline'
  end

  def view_fits_xml
    respond_to do |format|
      format.xml {render :xml => @bit_file.fits_xml}
    end
  end

  def create_fits_xml
    @bit_file.ensure_fits_xml
    redirect_to view_fits_xml_file_path(@bit_file, :format => 'xml')
  end

  protected

  def get_bit_file
    @bit_file = BitFile.find(params[:id])
  end

  def show_json(bit_file)
    Jbuilder.encode do |json|
      json.id bit_file.id
      json.directory_id bit_file.directory_id
      json.md5sum bit_file.md5sum
      json.name bit_file.name
      json.content_type bit_file.content_type
      json.ingested bit_file.dx_ingested
      json.size bit_file.size
      json.url bit_file.dx_url
    end
  end

end