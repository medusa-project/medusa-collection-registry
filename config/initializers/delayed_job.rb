#Various controls for delayed jobs.

# Delay in all environments
Delayed::Worker.delay_jobs = true
# Delay only in production, demo, and development
#Delayed::Worker.delay_jobs = !Rails.env.test?
#Delay only in production
#Delayed::Worker.delay_jobs = (Rails.env.production? || Rails.env.demo?)
Delayed::Worker.logger =  Logger.new(File.join(Rails.root, 'log', 'demo.log'))
#We set this in order to have some room on either side - recall that lower numbers take higher priority, with
#0 being maximum priority (and the default unless we set it as in the following line)
Delayed::Worker.default_priority = 50

#don't run all that often in development - can always run them off manually if needed
if Rails.env.development?
  Delayed::Worker.sleep_delay = 60
end

#Keep failed jobs so we can diagnose
Delayed::Worker.destroy_failed_jobs = false

Delayed::Worker.default_queue_name = 'default'

#Some jobs may take a long time - we may need to adjust this more
if Rails.env.production? || Rails.env.demo?
  Delayed::Worker.max_run_time = 96.hours
end