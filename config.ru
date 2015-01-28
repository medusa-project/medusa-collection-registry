# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
#set up delayed_job_web
if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == ENV['DJ_WEB_USER'] && password == ENV['DJ_WEB_PASSWORD']
  end
end
run MedusaRails3::Application
