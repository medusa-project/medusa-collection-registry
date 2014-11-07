And(/^the file group named '(.*)' has a cfs file for the path '(.*)' with red flags with fields:$/) do |name, path, table|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.ensure_file_at_relative_path(path)
  table.hashes.each do |h|
    cfs_file.red_flags.create(h)
  end
end

And(/^the file group named '(.*)' has a cfs file for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  file_group.cfs_directory.ensure_file_at_relative_path(path)
end

And(/^the file group named '(.*)' has a cfs file for the path '(.*)' with fields:$/) do |name, path, table|
  file_group = FileGroup.find_by(name: name)
  file = file_group.cfs_directory.ensure_file_at_relative_path(path)
  file.update_attributes!(table.hashes.first)
end

Then(/^the cfs file at path '(.*)' for the file group named '(.*)' should have fields:$/) do |path, name, table|
  file_group = FileGroup.find_by(name: name)
  file = file_group.cfs_directory.ensure_file_at_relative_path(path)
  table.hashes.first.each do |k, v|
    expect(file.send(k).to_s).to eq(v)
  end
end

Then(/^I should have downloaded the fixture file '(.*)'$/) do |name|
  expect(page.response_headers['Content-Disposition']).to match('attachment')
  expect(page.response_headers['Content-Disposition']).to match(name)
  expect(page.source).to eq(fixture_file_content(name))
end

Then(/^I should have viewed the fixture file '(.*)'$/) do |name|
  expect(page.response_headers['Content-Disposition']).to match('inline')
  expect(page.response_headers['Content-Disposition']).to match(name)
  expect(page.source).to eq(fixture_file_content(name))
end

Then(/^I should have downloaded a file '(.*)' with contents '(.*)'$/) do |name, contents|
  expect(page.response_headers['Content-Disposition']).to match('attachment')
  expect(page.response_headers['Content-Disposition']).to match(name)
  expect(page.source).to eq(contents)
end

Then(/^I should have viewed a file '(.*)' with contents '(.*)'$/) do |name, contents|
  expect(page.response_headers['Content-Disposition']).to match('inline')
  expect(page.response_headers['Content-Disposition']).to match(name)
  expect(page.source).to eq(contents)
end


def fixture_file_content(name)
  File.binread(File.join(Rails.root,  'features', 'fixtures', name))
end

When(/^I view the first red flag for the file group named '(.*)' for the cfs file for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  visit red_flag_path(cfs_file.red_flags.first)
end

Then(/^I should be editing the first red flag for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  expect(current_path).to eq(edit_red_flag_path(cfs_file.red_flags.first))
end

Then(/^I should be viewing the first red flag for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  expect(current_path).to eq(red_flag_path(cfs_file.red_flags.first))
end

Then(/^I should be viewing the cfs file for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  expect(current_path).to eq(cfs_file_path(cfs_file))
end

Then(/^I should be public viewing the cfs file for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  expect(current_path).to eq(public_cfs_file_path(cfs_file))
end


And(/^the cfs file at path '(.*)' for the file group named '(.*)' should have (\d+) red flags?$/) do |path, name, count|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_directory.find_file_at_relative_path(path)
  expect(cfs_file.red_flags.count).to eq(count.to_i)
end

When(/^I view the cfs file for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  visit cfs_file_path(file_group.cfs_file_at_path(path))
end

Given(/^I public view the cfs file for the file group named '(.*)' for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  visit public_cfs_file_path(file_group.cfs_file_at_path(path))
end

When(/^I run an initial cfs file assessment on the file group named '(.*)'$/) do |name|
  FileGroup.find_by(name: name).schedule_initial_cfs_assessment
end

Then(/^the file group named '(.*)' should have a cfs file for the path '(.*)' with results:$/) do |name, path, table|
  file_group = BitLevelFileGroup.find_by(name: name)
  cfs_file = file_group.cfs_file_at_path(path)
  expect(cfs_file).not_to be_nil
  table.raw.each do |field, value|
    expect(cfs_file.send(field).to_s).to eq(value)
  end
end

Then(/^the file group named '(.*)' should have a cfs directory for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.where(name: name).first
  expect(file_group.cfs_directory_at_path(path)).to be_a(CfsDirectory)
end

Then(/^the file group named '(.*)' should have a cfs directory$/) do |name|
  expect(BitLevelFileGroup.find_by(name: name).cfs_directory).to be_a(CfsDirectory)
end

Then(/^the file group named '(.*)' should not have a cfs file for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.where(name: name).first
  expect {file_group.cfs_file_at_path(path)}.to raise_error(RuntimeError)
end

Then(/^the file group named '(.*)' should not have a cfs directory for the path '(.*)'$/) do |name, path|
  file_group = FileGroup.where(name: name).first
  expect {file_group.cfs_directory_at_path(path)}.to raise_error(RuntimeError)
end


And(/^the file group named '(.*)' should have a cfs file for the path '(.*)' with fits attached$/) do |name, path|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_file_at_path(path)
  expect(cfs_file.fits_xml).not_to be_blank
end

Then(/^I should be on the fits info page for the cfs file at path '(.*)' for the file group named '(.*)'$/) do |path, name|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_file_at_path(path)
  expect(current_path).to eql(fits_xml_cfs_file_path(cfs_file))
end

And(/^the cfs file at path '(.*)' for the file group named '(.*)' has fits attached$/) do |path, name|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_file_at_path(path)
  cfs_file.ensure_fits_xml
end

And(/^the cfs file at path '(.*)' for the file group named '(.*)' has fits rerun$/) do |path, name|
  file_group = FileGroup.find_by(name: name)
  cfs_file = file_group.cfs_file_at_path(path)
  cfs_file.update_fits_xml
end

And(/^there are cfs files with fields:$/) do |table|
  table.hashes.each do |hash|
    FactoryGirl.create(:cfs_file, hash)
  end
end

When(/^I request JSON for the cfs file with id '(\d+)'$/) do |id|
  visit cfs_file_path(CfsFile.find(id), format: :json)
end