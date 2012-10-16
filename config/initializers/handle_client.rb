config_file = File.join(Rails.root, 'config', 'handle_client.yml')
app = MedusaRails3::Application
if File.exists?(config_file)
  handle_opts = YAML.load_file(config_file)
  app.medusa_host = handle_opts['medusa_host']
  app.handle_client = HandleServer::URLClient.new(handle_opts['handle_server'].symbolize_keys)
else
  app.medusa_host = nil
  app.handle_client = nil
end