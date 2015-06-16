require 'rake'

namespace :amazon do

  #Note that for this to work the medusa-glacier server must also be configured to
  #accept delete requests.
  desc 'Delete old amazon backups - FOR TEST SERVER ONLY'
  task delete_old_backups: :environment do
    old_backups = AmazonBackup.all.select {|ab| ab.updated_at < Date.today - 91.days}
    old_backups.each {|backup| backup.delete_archives_and_self}
  end
  
end
