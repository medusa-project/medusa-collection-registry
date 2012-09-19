# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActiveRecord::Base.transaction do

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
  ['Derivative Content', 'Master Content', 'Derivative Metadata', 'Master Metadata', 'Other'].each do |name|
    FileType.find_or_create_by_name(name)
  end

#Resource types
  ['text', 'cartographic', 'notated music', 'sound recording', 'sound recording-musical',
   'sound recording-nonmusical', 'still image', 'moving image', 'animated computer graphics',
   'three dimensional object', 'software, multimedia, mixed material'].each do |name|
    ResourceType.find_or_create_by_name(name)
  end

#PreservationPriorities
  {0.0 => 'migrated', 1.0 => 'low', 2.0 => 'medium', 3.0 => 'high', 4.0 => 'urgent'}.each do |priority, name|
    PreservationPriority.find_or_create_by_name(:name => name, :priority => priority)
  end

#Make sure every Collection has
# - a preservation priority
# - an attached IngestStatus
# - a uuid
  Collection.all.each do |c|
    c.preservation_priority = PreservationPriority.default unless c.preservation_priority
    c.ingest_status = IngestStatus.new(:state => :unstarted) unless c.ingest_status
    c.ensure_uuid
    c.save!
  end

end