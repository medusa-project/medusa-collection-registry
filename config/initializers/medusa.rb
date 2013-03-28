MedusaRails3::Application.medusa_config =
    YAML.load_file(File.join(Rails.root, 'config', 'medusa.yml'))[Rails.env]

