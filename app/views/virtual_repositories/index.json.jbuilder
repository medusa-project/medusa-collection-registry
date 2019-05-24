json.array! VirtualRepository.all do |virtual_repository|
  json.title virtual_repository.title
  json.repository_id virtual_repository.repository.id
  json.repository_uuid virtual_repository.repository.uuid
  json.collections do
    json.array! virtual_repository.collections, :id, :uuid
  end
end