#don't delay jobs in test environment
Delayed::Worker.delay_jobs = !Rails.env.test?

#don't run all that often in development - can always run them off manually if needed
if Rails.env.development?
  Delay::Worker.sleep_delay = 600
end