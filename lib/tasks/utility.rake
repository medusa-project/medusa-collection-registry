namespace :utility do
  desc 'Nudge accrual job to assessing after external copying and key removal'
  task :nudgejob, [:ingest_id] => [:environment] do |t, args|
    wf = Workflow::AccrualJob.find_by(id: args[:ingest_id])
    puts "no workflow accrual job found" unless wf
    next unless wf
    wf.perform_await_copy_messages
  end
end