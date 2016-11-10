require 'rake'

namespace :medusa do
  #Presumably to be called by cron. Will be obsoleted by new amazon backup system, but
  #useful for now.
  desc "Schedule Amazon backup for file groups with amqp accruals"
  task schedule_amqp_amazon_backups: :environment do
    begin
      file_group_ids = Settings.amqp_accrual.keys.collect { |k| Settings.amqp_accrual[k][:file_group_id] }
      file_groups = BitLevelFileGroup.where(id: file_group_ids).uniq!
      file_groups.each do |file_group|
        begin
          unless AmazonBackup.find_by(cfs_directory_id: file_group.cfs_directory_id, date: Date.today)
            AmazonBackup.create_and_schedule(User.find_by_uid('hding2@illinois.edu'), file_group.cfs_directory_id)
          end
        rescue Exception => e
          GenericErrorMailer.error("Unable to create Amazon Backup for AMQP accrual group: #{file_group.cfs_directory_id}. Details: #{e}")
        end
      end
    rescue Exception => e
      GenericErrorMailer.error("Unknown problem creating Amazon Backup for AMQP accrual group. Details: #{e}")
    end
  end
end