config = YAML.load_file(File.join(Rails.root, 'config', 'medusa.yml'))[Rails.env]
#cfs
MedusaRails3::Application.cfs_root = config['cfs']['root']