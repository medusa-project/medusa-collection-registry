namespace :local_identity do
  desc 'generate dev local identities'
  task :make_admins => :environment do
    # create local identity accounts for admins
    admins = Settings.admin.netids.split(",").collect {|x| x.strip || x}
    admins.each do |netid|
      email = "#{netid}@illinois.edu"
      name = "admin #{netid}"
      user = User.find_or_create_by(email: email)
      user.uid = email
      user.created_at = Time.zone.now
      user.save!
      identity = Identity.find_or_create_by(email: email)
      salt = BCrypt::Engine.generate_salt
      localpass = Settings.admin.localpass
      encrypted_password = BCrypt::Engine.hash_secret(localpass, salt)
      identity.password_digest = encrypted_password
      identity.update(password: localpass, password_confirmation: localpass)
      identity.name = name
      identity.created_at = Time.zone.now
      identity.save!
    end
  end
end
