namespace :medusa do
  namespace :delayed_job do

    desc 'Start delayed job'
    task :start => :environment do
      # Create the tmp/pids directory if it's not there
      unless File.exists?(delayed_job_pid_dir)
        sh "mkdir #{delayed_job_pid_dir}"
        sleep(2)
      end
      ENV['RAILS_ENV'] = Rails.env
      sh "script/delayed_job -p #{Rails.env} --pid-dir=#{delayed_job_pid_dir} start"
    end

    desc 'Stop delayed_job'
    task :stop => :environment do
      ENV['RAILS_ENV'] = Rails.env
      sh "script/delayed_job -p #{Rails.env} --pid-dir=#{delayed_job_pid_dir} stop"
    end

  end
end

def delayed_job_pid_dir()
  "#{Rails.root}/tmp/delayed_job_#{Rails.env}_pids"
end
