class ItemBulkImportMailer < MedusaBaseMailer

  def success(user, project, count)
    @project = project
    @count = count
    mail to: user.email, subject: 'Project items uploaded'
  end

  def failure(user, project, exception)
    @project = project
    @exception = exception
    mail to: [user.email, self.admin_address], subject: 'Error uploading project items'
  end
end
