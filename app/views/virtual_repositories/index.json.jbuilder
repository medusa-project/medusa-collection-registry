json.array! VirtualRepository.all do |virtual_repository|
  json.title virtual_repository.title
  json.repository_id virtual_repository.repository.id
  json.collections do
    json.array! virtual_repository.collections, :id
  end
end