ActiveRecord::Base.transaction do

#Storage media
  Settings.classes.storage_medium.media_names.each do |media_name|
    StorageMedium.find_or_create_by(name: media_name)
  end

#Resource types
  Settings.classes.resource_type.type_names.each do |name|
    ResourceType.find_or_create_by(name: name)
  end

  Settings.classes.static_page.default_pages.each do |key|
    unless StaticPage.find_by(key: key)
      StaticPage.create(key: key, page_text: "#{key.humanize} page")
    end
  end

#Some initial file format test reasons
  Settings.classes.file_format_test_reason.initial_reasons.each do |label|
    FileFormatTestReason.find_or_create_by(label: label)
  end

#load all views and functions used by the application
  Dir.chdir(File.join(Rails.root, 'db', 'views_and_functions')) do
    Dir['*.sql'].sort.each do |view_file|
      ActiveRecord::Base.connection.execute(File.read(view_file))
    end
  end

end
