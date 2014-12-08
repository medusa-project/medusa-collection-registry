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
    StorageMedium.find_or_create_by(name: media_name)
  end

#Resource types
  ['text', 'cartographic', 'notated music', 'sound recording', 'sound recording-musical',
   'sound recording-nonmusical', 'still image', 'moving image',
   'three dimensional object', 'software, multimedia', 'mixed material'].each do |name|
    ResourceType.find_or_create_by(name: name)
    if bad_type = ResourceType.find_by_name('software, multimedia, mixed material')
      bad_type.destroy
    end
    if bad_type = ResourceType.find_by_name('animated computer graphics')
      bad_type.destroy
    end
  end

#PreservationPriorities
  PreservationPriority.where(name: 'migrated').destroy_all
  {0.0 => 'ingested', 1.0 => 'low', 2.0 => 'medium', 3.0 => 'high', 4.0 => 'urgent'}.each do |priority, name|
    PreservationPriority.find_or_create_by(name: name, priority: priority)
  end

#Make sure every Collection has
# - a preservation priority
# - a uuid
# - a registered handle
  Collection.all.each do |c|
    c.preservation_priority = PreservationPriority.default unless c.preservation_priority
    c.ensure_rights_declaration
    c.ensure_uuid
    c.save!
    c.ensure_handle
  end

  FileGroup.all.each do |fg|
    fg.ensure_rights_declaration
    fg.save!
  end

end
