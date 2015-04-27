class FitsMailer < MedusaBaseMailer

  def success(user, target, missing_files, already_analyzed_files, currently_analyzed_files)
    @target = target
    @missing_files = missing_files
    @already_analyzed_files = already_analyzed_files
    @currently_analyzed_files = currently_analyzed_files
    mail(to: user.email, subject: 'FITS batch completed')
  end

end