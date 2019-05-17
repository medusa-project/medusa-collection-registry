json.array! @access_systems do |access_system|
  json.id access_system.id
  json.name access_system.name
  json.service_owner access_system.service_owner
  json.application_manager access_system.application_manager
end