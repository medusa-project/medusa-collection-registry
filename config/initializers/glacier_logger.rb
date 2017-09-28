Application.glacier_logger = Logger.new(File.join(Rails.root, 'log', 'glacier.log'))
Application.glacier_logger.level = Logger::DEBUG