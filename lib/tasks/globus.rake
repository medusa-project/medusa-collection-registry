require 'json'

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

  desc "get active task list"
  task get_active_task_list: :environment do
    bearer_token = GlobusToken.instance.bearer_token
    query = {
      "filter"     => "status:ACTIVE",
    }
    response = HTTParty.get("#{Workflow::GlobusTransfer::API_BASE}/task_list",
                            query: query,
                            headers: { 'Authorization' => "Bearer #{bearer_token}",
                                       'Content-Type' => 'application/json' })

    Rails.logger.warn response.to_yaml
    puts response.to_yaml
  end

  desc "get task list"
  task get_task_list: :environment do
    bearer_token = GlobusToken.instance.bearer_token
    response = HTTParty.get("#{Workflow::GlobusTransfer::API_BASE}/task_list",
                            headers: { 'Authorization' => "Bearer #{bearer_token}",
                                       'Content-Type' => 'application/json' })

    Rails.logger.warn response.to_yaml
    puts response.to_yaml
  end

  desc "cancel demo tasks"
  task cancel_demo_tasks: :environment do
    bearer_token = GlobusToken.instance.bearer_token
    query = {
      "filter"     => "status:ACTIVE",
      "num_results"     => "None",
    }
    response = HTTParty.get("#{Workflow::GlobusTransfer::API_BASE}/task_list",
                            query: query,
                            headers: { 'Authorization' => "Bearer #{bearer_token}",
                                       'Content-Type' => 'application/json' })

    response.parsed_response["DATA"].each do |task|
      task_id = CGI.escapeHTML(task["task_id"])
      if task["destination_endpoint_display_name"] == "medusa-demo-main"
        puts task_id
        cancel_response = HTTParty.post("#{Workflow::GlobusTransfer::API_BASE}/task/#{task_id}/cancel",
                                        headers: { 'Authorization' => "Bearer #{bearer_token}",
                                                   'Content-Type' => 'application/json' })
        puts "#{cancel_response.code} | #{cancel_response.message}"
      end
    end


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