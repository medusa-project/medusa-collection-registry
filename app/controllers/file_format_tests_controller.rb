class FileFormatTestsController < ApplicationController

  before_filter :require_logged_in
  before_action :find_file_format_test, only: [:edit, :update]

  def edit

  end

  def update
    if @file_format_test.update_attributes(allowed_update_params)
      redirect_to @cfs_file
    else
      render 'edit'
    end
  end

  def new
    @cfs_file = CfsFile.find(params[:cfs_file_id])
    @file_format_test = FileFormatTest.new(date: Date.today, cfs_file_id: @cfs_file.id, tester_email: current_user.email,
                                           file_format_profile: @cfs_file.random_file_format_profile)
  end

  def create
    @cfs_file = CfsFile.find(params[:file_format_test][:cfs_file_id])
    @file_format_test = FileFormatTest.create(allowed_create_params)
    if @file_format_test.save
      redirect_to @cfs_file
    else
      render 'new'
    end
  end

  protected

  def find_file_format_test
    @file_format_test = FileFormatTest.find(params[:id])
    @cfs_file = @file_format_test.cfs_file
  end

  def allowed_update_params
    params[:file_format_test].permit(:tester_email, :date, :pass, :notes, :file_format_profile_id, file_format_test_reason_ids: [])
  end

  def allowed_create_params
    params[:file_format_test].permit(:cfs_file_id, :tester_email, :date, :pass, :notes, :file_format_profile_id, file_format_test_reason_ids: [])
  end

end