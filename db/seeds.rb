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
  Collection.find_each do |c|
    c.preservation_priority = PreservationPriority.default unless c.preservation_priority
    c.ensure_rights_declaration
    c.ensure_uuid
    c.save!
    #c.ensure_handle
  end

  FileGroup.find_each do |fg|
    fg.ensure_rights_declaration
    fg.save!
  end

  %w(help landing down deposit_files request_training create_a_collection feedback policies technology staff).each do |key|
    unless StaticPage.find_by(key: key)
      StaticPage.create(key: key, page_text: "#{key.humanize} page")
    end
  end

  #Make sure that every cfs file has an associated file extension
  CfsFile.ensure_all_file_extensions

  #load all views used by the application
  Dir.chdir(File.join(Rails.root, 'db', 'views')) do
    Dir['*.sql'].sort.each do |view_file|
      ActiveRecord::Base.connection.execute(File.read(view_file))
    end
  end

  #Some initial file format test reasons
  ['saved with incorrect extension', 'corrupt', 'software unavailable'].each do |label|
    FileFormatTestReason.find_or_create_by(label: label)
  end

end
