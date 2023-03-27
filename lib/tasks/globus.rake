namespace :globus do
  desc "process workflow globus transfers"
  task process_transfers: :environment do
    Workflow::GlobusTransfer.remove_orphans
    min_batch_seconds = 10
    max_count = 190
    start_time = Time.now
    end_time = start_time + 55.minutes
    while (Time.now < end_time) do
      if Workflow::GlobusTransfer.where(state: [nil, 'SENT', 'ACTIVE']).count.positive?
        batch_start_seconds = Time.now.sec
        unsent_batch = Workflow::GlobusTransfer.where(state: nil).limit(max_count)
        spare_room = max_count - unsent_batch.count
        sent_batch = Workflow::GlobusTransfer.where(state: ['SENT', 'ACTIVE']).limit(spare_room)
        unsent_batch.each(&:process)
        sent_batch.each(&:process)
        batch_end_seconds = Time.now.sec
        wait_seconds =  min_batch_seconds - (batch_end_seconds - batch_start_seconds)
        sleep wait_seconds
      else
        sleep 300
      end

    end
  end
  desc "remove orphaned transfer records"
  task remove_orphans: :environment do
    Workflow::GlobusTransfer.remove_orphans
  end
end