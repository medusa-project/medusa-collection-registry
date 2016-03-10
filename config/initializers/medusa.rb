MedusaCollectionRegistry::Application.medusa_config =
  Config.new(YAML.load_file(File.join(Rails.root, 'config', 'medusa.yml'))[Rails.env])

