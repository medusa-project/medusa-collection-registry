# frozen_string_literal: true

require 'json'

class Workflow::GlobusTransfer < ApplicationRecord
  belongs_to :workflow_accrual_key, :class_name => 'Workflow::AccrualKey', foreign_key: 'workflow_accrual_key_id'
  API_BASE = 'https://transfer.api.globus.org/v0.10'

  def self.remove_orphans
    Workflow::GlobusTransfer.all.each do |transfer|
      transfer.destroy! unless transfer.workflow_accrual_key
    end
  end

  def self.process_completed_transfers
    num_sent = Workflow::GlobusTransfer.where(state: 'SENT').count
    num_checked = 0
    while num_checked < num_sent
      batch = Workflow::GlobusTransfer.where(state: 'SENT').limit(1000)
      batch.each do |transfer|
        transfer.update_attribute(:state, 'SUCCEEDED') if transfer.object_copied?
        num_checked = num_checked + 1
      end
    end
  end

  def process
    if state.nil?
      return false unless self.workflow_accrual_key

      submitted = self.submit
      if submitted
        self.state = "SENT"
        self.save
        self.workflow_accrual_key.update_attribute(:copy_requested, true)
      else
        Rails.logger.warn("submitted was false for Workflow::GlobusTransfer #{self.id}")
        return false
      end
    else
      self.update_attribute(:state, self.status) unless self.state == "SUCCEEDED"
    end
    true
  end

  def submit
    begin
      bearer_token = GlobusToken.instance.bearer_token
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

      if transfer_response.code == 409
        Rails.logger.warn "Globus conflict in submit for #{workflow_accrual_key_id}"
        Rails.logger.warn transfer_response.message
      end

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
      bearer_token = GlobusToken.instance.bearer_token

      raise('Missing Globus bearer_token') unless bearer_token

      cancel_response = HTTParty.post("#{Workflow::GlobusTransfer::API_BASE}/task/#{task_id}/cancel",
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

    return 'no task_id present' unless task_id.present?


    begin
      bearer_token = GlobusToken.instance.bearer_token
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
    check_key = destination_path
    # remove leading slash
    check_key = check_key[1..-1] if check_key[0] == "/"
    StorageManager.instance.main_root.exist?(check_key)
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

end
