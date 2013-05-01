#don't delay jobs in test environment - sometimes we may want to also not delay in development for debugging -
#use second line for this
Delayed::Worker.delay_jobs = !Rails.env.test?
#Delayed::Worker.delay_jobs = false

#don't run all that often in development - can always run them off manually if needed
if Rails.env.development?
  Delayed::Worker.sleep_delay = 60
end