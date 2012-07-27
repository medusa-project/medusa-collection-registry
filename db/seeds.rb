# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Storage media
['CD-Rom', 'DVD', 'Blu-Ray', 'other optical disk',
'external hard drive', 'internal hard drive',
'Iomega media (e.g. ZIP, JAZ disks)', 'other computer disk cartridge',
'file server', 'cloud storage',
'computer tape reel', 'computer tape cartridge', 'computer tape cassette',
'flash drive', 'memory card (e.g SD card, CompactFlash',
'computer card (e.g. punchboard)', 'paper tape'].each do |media_name|
  StorageMedium.find_or_create_by_name(media_name)
end
