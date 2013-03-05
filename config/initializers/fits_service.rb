require 'fits'

config = File.join(Rails.root, 'config', 'fits_service.yml')[Rails.env]
Fits::Service.instance.configure(config) unless Rails.env == 'test'