namespace :globus do
  desc "process workflow globus transfers"
  task process_transfers: :environment do
    manager = GlobusRateManager.instance()
    start_time = Time.now
    end_time = start_time + 58.minutes
    max_count = 190
    while (Time.now < end_time) do
      if Workflow::GlobusTransfer.where(state: nil).count.positive?
        batch = Workflow::GlobusTransfer.where(state: nil).limit(max_count)
        process_batch(batch: batch, manager: manager)
      elsif Workflow::GlobusTransfer.where(state: ['SENT', 'ACTIVE']).count.positive?
        batch = Workflow::GlobusTransfer.where(state: ['SENT', 'ACTIVE']).limit(max_count)
        process_batch(batch: batch, manager: manager)
      else
        sleep 300
      end
    end
  end

  desc "remove orphaned transfer records"
  task remove_orphans: :environment do
    Workflow::GlobusTransfer.remove_orphans
  end

  def process_batch(batch:, manager:)

    batch.each do |transfer|
      unless manager.too_soon?
        transfer.process
        manager.add_call
      end
    end
  end

end