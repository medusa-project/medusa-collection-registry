require 'singleton'

class GlobusToken < ApplicationRecord
  include Singleton

  def expired?
    return true if self.created_at.nil?

    Time.now.utc > self.created_at + self.expires_in - 5.seconds
  end

  def bearer_token

    unless access_token.nil?
      return access_token unless expired?
    end

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
      Rails.logger.warn("Globus token_response: #{token_response.code}, #{token_response.message}")
      return nil
    end



    self.access_token = token_response['access_token']
    self.expires_in = token_response['expires_in']
    self.body = token_response.to_s
    self.save
  rescue StandardError => e
    Rails.logger.warn("#{e.class} getting bearer_token for Globus: #{e.message}")
    return nil
  end

end
