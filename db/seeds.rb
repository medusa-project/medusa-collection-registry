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
  CHANGE_TYPES = {'cartographic' => 'maps', 'notated music' => 'sheet music',
                  'sound recording' => 'audio', 'moving image' => 'video'}
  UPDATE_TYPES = {'sound recording-musical' => 'audio', 'sound recording-nonmusical' => 'audio'}
  DELETE_TYPES = ['software, multimedia']
  OLD_TYPES = ['text', 'still image', 'three dimensional object', 'mixed material']
  NEW_TYPES = ['newspapers', 'archives', 'photographs', 'born digital materials', 'oral histories',
               'books and manuscripts', 'scholarly publications', 'posters', 'audiovisual materials',
               'postcards', 'thesis and dissertations']
  (OLD_TYPES + NEW_TYPES).each do |name|
    ResourceType.find_or_create_by(name: name)
  end
  DELETE_TYPES.each do |name|
    ResourceType.find_by(name: name).try(:destroy!)
  end
  CHANGE_TYPES.each do |old, new|
    if resource_type = ResourceType.find_by(name: old)
      resource_type.name = new
      resource_type.save!
    end
  end
  UPDATE_TYPES.each do |old, new|
    old_type = ResourceType.find_by(name: old)
    new_type = ResourceType.find_by(name: new)
    return unless old_type and new_type
    old_type.resource_typeable_resource_type_joins.each do |join|
      resource_typeable = join.resource_typeable
      resource_typeable.resource_types << new_type
    end
    old_type.destroy!
  end

#PreservationPriorities
  {0.0 => 'ingested', 1.0 => 'low', 2.0 => 'medium', 3.0 => 'high', 4.0 => 'urgent'}.each do |priority, name|
    PreservationPriority.find_or_create_by(name: name, priority: priority)
  end

  %w(help landing down deposit_files request_training create_a_collection feedback policies technology staff).each do |key|
    unless StaticPage.find_by(key: key)
      StaticPage.create(key: key, page_text: "#{key.humanize} page")
    end
  end

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
