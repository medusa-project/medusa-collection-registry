Given(/^the virtual repository with title '(.*)' has associated collections with title:$/) do |title, table|
  virtual_repository = VirtualRepository.find_by(title: title)
  table.headers.each do |collection_title|
    virtual_repository.collections << Collection.find_by(title: collection_title)
  end
end