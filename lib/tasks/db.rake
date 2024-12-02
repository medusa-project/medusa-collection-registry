namespace :db do
  desc 'Check if the database exists'
  task exists: :environment do
    begin
      ActiveRecord::Base.connection
      puts "Database exists."
    rescue ActiveRecord::NoDatabaseError
      puts "Database does not exist."
      exit 1
    end
  end
end