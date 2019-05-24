json.array! VirtualRepository.all do |virtual_repository|
  json.repository_id virtual_repository.repository.id
end