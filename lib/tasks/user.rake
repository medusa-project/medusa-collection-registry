namespace :user do

  desc "ensure a local user"
  task :ensure_local_user, [:name,:email,:password] => :environment do |t, args|
    return nil if Rails.env.production?

    User.find_or_create_local_user(name: args.name,
                           email: args.email,
                           password: args.password )
  end

end