class DownloaderMailer < MedusaBaseMailer
  
  def directory_complete(cfs_directory, email, response)
    @cfs_directory = cfs_directory
    @response = response
    mail(to: email)
  end

  def directory_error(cfs_directory, email, response)
    @cfs_directory = cfs_directory
    @response = response
    mail(to: email)
  end

  def directory_error_admin(cfs_directory, handler, response)
    @cfs_directory = cfs_directory
    @response = response
    @handler = handler
    mail(to: self.class.admin_address)
  end

  def file_list_complete(cfs_files, email, response)
    @cfs_files = cfs_files
    @response = response
    mail(to: email)
  end

  def file_list_error(cfs_files, email, response)
    @cfs_files = cfs_files
    @response = response
    mail(to: email)
  end

  def file_list_error_admin(cfs_files, handler, response)
    @cfs_files = cfs_files
    @response = response
    @handler = handler
    mail(to: self.class.admin_address)
  end

end