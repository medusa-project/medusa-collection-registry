json.extract! globus_token, :id, :access_token, :expires_in, :body, :created_at, :updated_at
json.url globus_token_url(globus_token, format: :json)
