config_file = File.join(Rails.root, 'config', 'handle_client.yml')
app = MedusaCollectionRegistry::Application
app.medusa_host = nil
app.handle_client = nil
if File.exists?(config_file)
  if handle_opts = YAML.load_file(config_file)[Rails.env]
    app.medusa_host = handle_opts['medusa_host']
    app.handle_client = HandleServer::URLClient.new(handle_opts['handle_server'].symbolize_keys)
  end
end
