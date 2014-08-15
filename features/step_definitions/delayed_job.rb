#TODO - this is for compatibility with the original testing regime where delayed jobs were turned off
#and everything run synchronously. So this step is added in to all those tests at the appropriate time
#However, for new tests two things can be done - test the creation of the job and also test the running
#of the job (possibly using this step) assuming that it exists. This will allow us to sanely test things
#like the amazon backup where we can't really run the job.
#It may not be worth the time now to go back and rewrite all the old tests, but that could be done at some point.
And /^delayed jobs are run$/ do
  Delayed::Worker.new.work_off
end