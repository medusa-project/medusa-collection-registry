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

  desc "display access token response"
  task display_token_response: :environment do
    client_id = Settings.globus.client_id
    client_secret = Settings.globus.client_secret
    auth_root = 'https://auth.globus.org'
    token_path = '/v2/oauth2/token'
    body = { 'grant_type' => 'client_credentials',
             'client_id' => client_id,
             'client_secret' => client_secret,
             'scope' => 'urn:globus:auth:scope:transfer.api.globus.org:all' }

    token_response = HTTParty.post("#{auth_root}#{token_path}", body: body)

    Rails.logger.warn token_response.to_yaml
    puts token_response.to_yaml
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