namespace :globus do
  desc "process workflow globus transfers"
  task process_transfers: :environment do
    min_batch_seconds = 10
    max_count = 190
    start_time = Time.now
    end_time = start_time + 58.minutes
    while (Time.now < end_time) do
      break unless Workflow::GlobusTransfer.where(state: [nil, 'SENT', 'ACTIVE']).count.positive?

      batch_start_seconds = Time.now.sec
      unsent_batch = Workflow::GlobusTransfer.where(state: nil).limit(max_count)
      spare_room = max_count - unsent_batch.count
      sent_batch = Workflow::GlobusTransfer.where(state: ['SENT', 'ACTIVE']).limit(spare_room)
      unsent_batch.each(&:process)
      sent_batch.each(&:process)
      batch_end_seconds = Time.now.sec
      wait_seconds =  min_batch_seconds - (batch_end_seconds - batch_start_seconds)
      puts wait_seconds
      sleep wait_seconds
    end
  end
  desc "remove orphaned transfer records"
  task remove_orphans: :environment do
    Workflow::GlobusTransfer.all do |transfer|
      accrual_key = Workflow::AccrualKey.find_by(id: transfer.workflow_accrual_key_id)
      if accrual_key
        puts "accrual_key #{accrual_key.id} found for transfer #{transfer.id}"
      else
        puts "accrual_key #{accrual_key.id} not found for transfer #{transfer.id}"
      end
      transfer.destroy if accrual_key.nil?
    end
  end
end