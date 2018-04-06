class ItemBulkImportMailer < MedusaBaseMailer

  def success(user, project, file_name, count)
    @project = project
    @count = count
    @file_name = file_name
    mail to: user.email, subject: subject('Project items uploaded')
  end

  def failure(user, project, file_name, exception)
    @project = project
    @exception = exception
    @file_name = file_name
    mail to: [user.email, self.admin_address], subject: subject('Error uploading project items')
  end
end
