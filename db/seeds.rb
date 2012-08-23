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

#File types
['Access Content', 'Archival Content', 'Other Metadata', 'Master Metadata', 'Other'].each do |name|
  FileType.find_or_create_by_name(name)
end

#Content types
['digitized book', 'digitized images', 'born digital images',
 'born digital audio', 'digitized audio', 'born digital moving image',
 'digitized moving image', 'electronic thesis or dissertation',
 'research data', 'metadata'].each do |name|
  ContentType.find_or_create_by_name(name)
end

#Object types
['Books and pamphlets', 'Photographs/slides/negatives', 'Music (audio files)',
 'Newspapers', 'Posters and broadsides', 'Sheet music and scores', 'Periodicals',
 'Prints and drawings', 'Physical artifacts', 'Interactive learning objects',
 'Oral histories (audio files)', 'Physical specimens (plants/animals/etc)'].each do |name|
  ObjectType.find_or_create_by_name(name)
end

#PreservationPriorities
{0.0 => 'migrated', 1.0 => 'low', 2.0 => 'medium', 3.0 => 'high', 4.0 => 'urgent'}.each do |priority, name|
  PreservationPriority.find_or_create_by_name(:name => name, :priority => priority)
end