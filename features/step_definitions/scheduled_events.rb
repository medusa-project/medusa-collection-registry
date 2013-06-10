Then(/^the file group named '(.*)' should have a scheduled event with fields:$/) do |name, table|
  file_group = FileGroup.find_by_name(name)
  table.hashes.each do |hash|
    file_group.scheduled_events.where(hash).first.should be_true
  end
end

