require_relative 'config'
app = MedusaCollectionRegistry::Application
app.medusa_host = nil
app.handle_client = nil
if Settings.handle_client.present?
  app.medusa_host = Settings.handle_client.medusa_host
  app.handle_client = HandleServer::URLClient.new(Settings.handle_client.handle_server.to_h.symbolize_keys)
end
