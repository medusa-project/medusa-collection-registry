config = YAML.load_file(File.join(Rails.root, 'config', 'medusa.yml'))[Rails.env]

#cfs
Cfs.instance.configure(config['cfs'])