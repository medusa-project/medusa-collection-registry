# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
#set up delayed_job_web

DelayedJobWeb.use Rack::Auth::Basic do |username, password|
  username == Settings.medusa.amqp.user && password == Settings.medusa.amqp.password and username.present? and password.present?
end

run Rails.application
