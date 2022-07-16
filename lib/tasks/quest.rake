require "addressable/uri"

namespace :quest do
  desc 'hit quest directory service'
  task :blast_directory => :environment do

    group = "Library Medusa Super Admins"

    User.all.each do |user|
      puts user.email

      next if user.email.nil?

      email_parts = user.email.split("@")
      next unless email_parts.last == 'illinois.edu'

      netid = email_parts.first
      begin
        puts "checking #{netid}"
        open("https://quest.library.illinois.edu/directory/ad/#{netid}/ismemberof/#{Addressable::URI.encode(group)}").read
        puts "OK"
      rescue OpenURI::HTTPError
        puts "netid #{netid} not found"
      end
    end
  end
end