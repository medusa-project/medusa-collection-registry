#TODO - this is for compatibility with the original testing regime where delayed jobs were turned off
#and everything run synchronously. So this step is added in to all those tests at the appropriate time
#However, for new tests two things can be done - test the creation of the job and also test the running
#of the job (possibly using this step) assuming that it exists. This will allow us to sanely test things
#like the amazon backup where we can't really run the job.
#It may not be worth the time now to go back and rewrite all the old tests, but that could be done at some point.
And /^delayed jobs are run$/ do
  begin
    #Set quiet to false to see the delayed jobs run
    Delayed::Worker.new(quiet: true).work_off
  rescue Exception => e
    message = "DELAYED JOB ERROR: #{e}"
    Rails.logger.error message
    puts message
    raise
  end
end

And(/^there should be (\d+) delayed jobs?$/) do |count|
  expect(Delayed::Job.count).to eq(count.to_i)
end