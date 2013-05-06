#don't delay jobs in test environment - sometimes we may want to also not delay in development for debugging -
#use second line for this
Delayed::Worker.delay_jobs = !Rails.env.test?
#Delayed::Worker.delay_jobs = false

#We set this in order to have some room on either side - recall that lower numbers take higher priority, with
#0 being maximum priority (and the default unless we set it as in the following lineI have a small question about the used Roland GK-2A pickup you have listed on the website (sku: 200U-2052). The description says 'pickup only' and I just wanted to know if that literally means just the pickup/controller assembly or if it includes the endpin mounting bracket for the controller.)
Delayed::Worker.default_priority = 50

#don't run all that often in development - can always run them off manually if needed
if Rails.env.development?
  Delayed::Worker.sleep_delay = 60
end