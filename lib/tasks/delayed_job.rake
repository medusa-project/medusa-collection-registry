DJ_QUEUES = {default: 3, glacier: 1}

namespace :medusa do
  namespace :delayed_job do

    desc 'Start delayed job'
    task start: :environment do
      ENV['RAILS_ENV'] = Rails.env
      DJ_QUEUES.each do |queue, count|
        # Create the tmp/pids directory if it's not there
        unless File.exists?(delayed_job_pid_dir(queue))
          sh "mkdir #{delayed_job_pid_dir(queue)}"
          sleep(2)
        end
        start_jobs(queue, count)
      end
    end

    desc 'Stop delayed_job'
    task stop: :environment do
      ENV['RAILS_ENV'] = Rails.env
      DJ_QUEUES.each do |queue, count|
        stop_jobs(queue)
      end
    end

  end
end

def start_jobs(queue, count)
  sh "script/delayed_job -p #{Rails.env} --pid-dir=#{delayed_job_pid_dir(queue)} -n #{count} --queue=#{queue} start"
end

def stop_jobs(queue)
  sh "script/delayed_job -p #{Rails.env} --pid-dir=#{delayed_job_pid_dir(queue)} stop"
end

def delayed_job_pid_dir(queue)
  "#{Rails.root}/tmp/delayed_job_#{Rails.env}_#{queue}_pids"
end
