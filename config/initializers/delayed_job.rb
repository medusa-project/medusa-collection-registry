#don't delay jobs in test environment - sometimes we may want to also not delay in development for debugging -
#use second line for this
Delayed::Worker.delay_jobs = !Rails.env.test?
#Delayed::Worker.delay_jobs = false

#We set this in order to have some room on either side - recall that lower numbers take higher priority, with
#0 being maximum priority (and the default unless we set it as in the following line)
Delayed::Worker.default_priority = 50

#don't run all that often in development - can always run them off manually if needed
if Rails.env.development?
  Delayed::Worker.sleep_delay = 60
end

#Keep failed jobs so we can diagnose
Delayed::Worker.destroy_failed_jobs = false