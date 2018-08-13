And(/^the external file group with title '([^']*)' has a related bit level file group$/) do |title|
  external_file_group = ExternalFileGroup.find_by(title: title)
  bit_level_file_group = FactoryBot.create(:bit_level_file_group)
  external_file_group.target_file_groups << bit_level_file_group
end
