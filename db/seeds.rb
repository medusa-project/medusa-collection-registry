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
  TYPES = ['text', 'still image', 'three dimensional object', 'mixed material',
           'maps', 'sheet music', 'audio', 'video',
           'newspapers', 'archives', 'photographs', 'born digital materials', 'oral histories',
           'books and manuscripts', 'scholarly publications', 'posters', 'audiovisual materials',
           'postcards', 'thesis and dissertations']
  TYPES.each do |name|
    ResourceType.find_or_create_by(name: name)
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

#load all views and functions used by the application
  Dir.chdir(File.join(Rails.root, 'db', 'views_and_functions')) do
    Dir['*.sql'].sort.each do |view_file|
      ActiveRecord::Base.connection.execute(File.read(view_file))
    end
  end

#Some initial file format test reasons
  ['saved with incorrect extension', 'corrupt', 'software unavailable'].each do |label|
    FileFormatTestReason.find_or_create_by(label: label)
  end

end
