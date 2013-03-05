require 'fits'

config = YAML.load_file(File.join(Rails.root, 'config', 'fits_service.yml'))[Rails.env]
Fits::Service.instance.configure(config) unless Rails.env == 'test'