#don't delay jobs in test environment
Delayed::Worker.delay_jobs = !Rails.env.test?