xml.instruct!
xml.mods(:version => '3.4', 'xsi:schemaLocation' => 'http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/mods.xsd',
         'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance", :xmlns => "http://www.loc.gov/mods/v3") do
  xml.titleInfo do
    xml.title @collection.title
  end
  xml.identifier(@collection.uuid, :type => 'uuid')
  xml.identifier(@collection.handle, :type => 'handle')
  @collection.resource_types.each do |resource_type|
    xml.typeOfResource(resource_type.name, :collection => 'yes')
  end
  xml.abstract @collection.description
  xml.location do
    xml.url(@collection.access_url, :access => 'object in context', :usage => 'primary')
  end
  xml.originInfo do
    xml.publisher(@collection.repository.title)
    xml.dateOther(@collection.start_date, :point => 'start')
    xml.dateOther(@collection.end_date, :point => 'end')
  end
end