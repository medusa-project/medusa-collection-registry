config = File.join(Rails.root, 'config', 'fits_service.yml')[Rails.env]
FitsService.instance.configure(config) unless Rails.env == 'test'