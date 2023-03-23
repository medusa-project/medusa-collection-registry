# frozen_string_literal: true

require 'json'

class Workflow::GlobusTransfer < ApplicationRecord
  belongs_to :workflow_accrual_key, :class_name => 'Workflow::AccrualKey', foreign_key: 'workflow_accrual_key_id'
  API_BASE = 'https://transfer.api.globus.org/v0.10'

  def process
    if state.nil?
      submitted = self.submit
      if submitted == true
        self.state = "SENT"
        self.save
        self.workflow_accrual_key.update_attribute(:copy_requested, true)
      end
    else
      self.update_attribute('state', self.status)
    end
  end

  def submit
    begin
      bearer_token = Workflow::GlobusTransfer.bearer_token
      return false unless bearer_token

      source_activation_path = "#{Workflow::GlobusTransfer::API_BASE}/endpoint/#{source_uuid}/autoactivate"
      destination_activation_path = "#{Workflow::GlobusTransfer::API_BASE}/endpoint/#{destination_uuid}/autoactivate"

      HTTParty.post(source_activation_path, headers: { 'Authorization' => "Bearer #{bearer_token}" })
      HTTParty.post(destination_activation_path, headers: { 'Authorization' => "Bearer #{bearer_token}" })

      submission_id_response = HTTParty.get("#{Workflow::GlobusTransfer::API_BASE}/submission_id",
                                            headers: { 'Authorization' => "Bearer #{bearer_token}",
                                                       'Content-Type' => 'application/json' })
      submission_id = submission_id_response['value']

      submission_json = { DATA_TYPE: 'transfer',
                          submission_id: submission_id,
                          source_endpoint: source_uuid,
                          destination_endpoint: destination_uuid,
                          label: "workflow_accrual_key#{workflow_accrual_key_id}",
                          sync_level: nil,
                          DATA: [{ source_path: source_path,
                                   destination_path: destination_path,
                                   recursive: recursive,
                                   DATA_TYPE: 'transfer_item' }] }.to_json
      transfer_response = HTTParty.post("#{Workflow::GlobusTransfer::API_BASE}/transfer",
                                        body: submission_json,
                                        headers: { 'Authorization' => "Bearer #{bearer_token}",
                                                   'Content-Type' => 'application/json' })

      unless [202, 200].include?(transfer_response.code)
        Rails.logger.warn "Globus transfer response for #{workflow_accrual_key_id}: #{transfer_response.code}, #{transfer_response.message}"
        return false
      end

      #Rails.logger.warn("Globus transfer response for #{workflow_accrual_key_id}: #{transfer_response.code}, #{transfer_response.message}")
      self.request_id = transfer_response['request_id']
      self.task_id = transfer_response['task_id']
      self.task_link = transfer_response['task_link']['href']
      return true
    rescue StandardError => e
      Rails.logger.warn("#{e.class} when trying Globus transfer for workflow accrual key #{workflow_accrual_key_id}, #{e.message}")
      return false
    end
  end

  def cancel
    return 'no task_id present' unless task_id.present?

    begin
      bearer_token = Workflow::GlobusTransfer.bearer_token

      raise('Missing Globus bearer_token') unless bearer_token

      cancel_response = HTTParty.post("#{Workflow::GlobusTransfer::API_BASE}task/#{task_id}/cancel",
                                      headers: { 'Authorization' => "Bearer #{bearer_token}",
                                                 'Content-Type' => 'application/json' })
      unless cancel_response.code == 200 || cancel_response.code == 404
        raise("Globus cancel response for #{id}: #{cancel_response.code}, #{cancel_response.message}")
      end
      
      self.request_id = nil
      self.task_id = nil
      self.task_link = nil
      self.submitted = nil
      save
    rescue StandardError => e
      Rails.logger.warn("#{e.class} when cancelling Globus transfer for workflow accrual key #{workflow_accrual_key_id}, #{e.message}")
      return false
    end

  end

  def status

    return 'SUCCEEDED' if object_copied?

    return 'no task_id present' unless task_id.present?

    begin
      bearer_token = Workflow::GlobusTransfer.bearer_token
      raise('Missing Globus bearer_token') unless bearer_token

      response = HTTParty.get("#{Workflow::GlobusTransfer::API_BASE}/task/#{task_id}",
                              headers: { 'Authorization' => "Bearer #{bearer_token}",
                                         'Content-Type' => 'application/json' })
      case response.code
      when 200
        response_json =  JSON.parse(response.body)
        return response_json["status"]
      when 409
        return "ACTIVE"
      else
        raise("Unhandled Globus status response for #{id}: #{response.code}, #{response.message}")
      end
    rescue StandardError => e
      Rails.logger.warn "error getting status for #{id}: #{e.message}"
      "ERROR"
    end
  end

  def object_copied?
    StorageManager.instance.main_root.exist?(workflow_accrual_key.key)
  end

  def event_list
    return 'no task_id present' unless task_id.present?

    begin
      bearer_token = Workflow::GlobusTransfer.bearer_token

      raise('Missing Globus bearer_token') unless bearer_token

      response = HTTParty.get("#{Workflow::GlobusTransfer::API_BASE}/task/#{task_id}/event_list",
                              headers: { 'Authorization' => "Bearer #{bearer_token}",
                                         'Content-Type' => 'application/json' })
      unless response.code == 200
        raise("Globus status response for #{id}: #{response.code}, #{response.message}")
      end

      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.warn "error getting event list for #{id}: #{e.message}"
      'error getting event list'
    end
  end

  def self.bearer_token
    client_id = Settings.globus.client_id
    client_secret = Settings.globus.client_secret
    auth_root = 'https://auth.globus.org'
    token_path = '/v2/oauth2/token'
    body = { 'grant_type' => 'client_credentials',
             'client_id' => client_id,
             'client_secret' => client_secret,
             'scope' => 'urn:globus:auth:scope:transfer.api.globus.org:all' }

    token_response = HTTParty.post("#{auth_root}#{token_path}", body: body)

    unless token_response.code == 200
      raise("Globus token_response: #{token_response.code}, #{token_response.message}")
    end

    token_response['access_token']
  rescue StandardError => e
    Rails.logger.warn("#{e.class} getting bearer_token for Globus: #{e.message}")
    nil
  end
end
