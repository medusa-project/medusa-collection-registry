def ensuring_cfs_file_at_path_for_file_group_titled(path, title)
  file_group = BitLevelFileGroup.find_by(title: title)
  cfs_file = file_group.ensure_file_at_relative_path(path)
  yield cfs_file if block_given?
end

And(/^the file group titled '([^']*)' has a cfs file for the path '([^']*)' with red flags with fields:$/) do |title, path, table|
  ensuring_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file|
    table.hashes.each do |h|
      cfs_file.red_flags.create(h)
    end
  end
end

And(/^the file group titled '([^']*)' has a cfs file for the path '([^']*)' with fields:$/) do |title, path, table|
  ensuring_cfs_file_at_path_for_file_group_titled(path, title) do |file|
    file.update_attributes!(table.hashes.first)
  end
end

Then(/^the cfs file at path '([^']*)' for the file group titled '([^']*)' should have fields:$/) do |path, title, table|
  ensuring_cfs_file_at_path_for_file_group_titled(path, title) do |file|
    table.hashes.first.each do |k, v|
      expect(file.send(k).to_s).to eq(v)
    end
  end
end

Then(/^I should have downloaded the fixture file '([^']*)'$/) do |name|
  check_cfs_file_download('attachment', name, fixture_file_content(name))
end

Then(/^I should have viewed the fixture file '([^']*)'$/) do |name|
  check_cfs_file_download('inline', name, fixture_file_content(name))
end

def check_cfs_file_download(disposition, file_name, file_contents)
  expect(page.response_headers['Content-Disposition']).to match(disposition)
  expect(page.response_headers['Content-Disposition']).to match(file_name)
  expect(page.source).to eq(file_contents)
end

And(/^I click on '([^']*)' in the cfs file metadata$/) do |string|
  within('#cfs-file-metadata') do
    click_on string
  end
end

def fixture_file_content(name)
  File.binread(File.join(Rails.root, 'features', 'fixtures', name))
end

def with_cfs_file_at_path_for_file_group_titled(path, title)
  file_group = BitLevelFileGroup.find_by(title: title)
  cfs_file = file_group.find_file_at_relative_path(path)
  yield cfs_file, file_group
end

When(/^I view the first red flag for the file group titled '([^']*)' for the cfs file for the path '([^']*)'$/) do |title, path|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    visit red_flag_path(cfs_file.red_flags.first)
  end
end

Then(/^I should be editing the first red flag for the file group titled '([^']*)' for the path '([^']*)'$/) do |title, path|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    expect(current_path).to eq(edit_red_flag_path(cfs_file.red_flags.first))
  end
end

Then(/^I should be viewing the first red flag for the file group titled '([^']*)' for the path '([^']*)'$/) do |title, path|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    expect(current_path).to eq(red_flag_path(cfs_file.red_flags.first))
  end
end

Then(/^I should be viewing the cfs file for the file group titled '([^']*)' for the path '([^']*)'$/) do |title, path|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    expect(current_path).to eq(cfs_file_path(cfs_file))
  end
end

And(/^the cfs file at path '([^']*)' for the file group titled '([^']*)' should have (\d+) red flags?$/) do |path, title, count|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    expect(cfs_file.red_flags.count).to eq(count.to_i)
  end
end

When(/^I view the cfs file for the file group titled '([^']*)' for the path '([^']*)'$/) do |title, path|
  file_group = FileGroup.find_by(title: title)
  visit cfs_file_path(file_group.find_file_at_relative_path(path))
end

When(/^I download the cfs file for the file group titled '([^']*)' for the path '([^']*)'$/) do |title, path|
  file_group = FileGroup.find_by(title: title)
  visit download_cfs_file_path(file_group.find_file_at_relative_path(path))
end

Then(/^the file group titled '([^']*)' should have a cfs file for the path '([^']*)' with results:$/) do |title, path, table|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    expect(cfs_file).not_to be_nil
    table.raw.each do |field, value|
      expect(cfs_file.send(field).to_s).to eq(value)
    end
  end
end

Then(/^the file group titled '([^']*)' should have a cfs file for the path '([^']*)'$/) do |title, path|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    expect(cfs_file).not_to be_nil
  end
end

=begin
Then(/^the file group titled '([^']*)' should have a cfs file for the path '([^']*)' matching '([^']*)'$/) do |title, path, text|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    expect(cfs_file).not_to be_nil
    file_content = cfs_file.with_input_io do |io|
      io.read
    end
    expect(file_content).to match(text)
  end
end
=end

Then(/^the file group titled '([^']*)' should have a cfs directory for the path '([^']*)'$/) do |title, path|
  file_group = FileGroup.find_by(title: title)
  expect(file_group.find_directory_at_relative_path(path)).to be_a(CfsDirectory)
end

Then(/^the file group titled '([^']*)' should not have a cfs file for the path '([^']*)'$/) do |title, path|
  file_group = FileGroup.find_by(title: title)
  expect { file_group.find_file_at_relative_path(path) }.to raise_error(RuntimeError)
end

Then(/^the file group titled '([^']*)' should not have a cfs directory for the path '([^']*)'$/) do |title, path|
  file_group = FileGroup.find_by(title: title)
  expect { file_group.find_directory_at_relative_path(path) }.to raise_error(RuntimeError)
end

And(/^the file group titled '([^']*)' should have a cfs file for the path '([^']*)' with fits attached$/) do |title, path|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    expect(cfs_file.fits_xml).not_to be_blank
  end
end

Then(/^I should be on the fits info page for the cfs file at path '([^']*)' for the file group titled '([^']*)'$/) do |path, title|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    expect(current_path).to eql(fits_cfs_file_path(cfs_file, format: :xml))
  end
end

And(/^the cfs file at path '([^']*)' for the file group titled '([^']*)' has fits attached$/) do |path, title|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    cfs_file.ensure_fits_xml
  end
end

And(/^the cfs file at path '([^']*)' for the file group titled '([^']*)' should have been fixity and fits reset$/) do |path, title|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    %i(md5_sum size mtime content_type_id fixity_check_time fixity_check_status fits_xml fits_data).each do |field|
      expect(cfs_file.send(field)).to be_nil
    end
    expect(cfs_file.fits_serialized).to eq(false)
    expect(cfs_file.events.where(key: 'fixity_reset').count).to eql(1)
  end
end

And(/^the cfs file at path '([^']*)' for the file group titled '([^']*)' has fits rerun$/) do |path, title|
  with_cfs_file_at_path_for_file_group_titled(path, title) do |cfs_file, file_group|
    cfs_file.update_fits_xml
  end
end

And(/^there are cfs files with fields:$/) do |table|
  table.hashes.each do |hash|
    FactoryBot.create(:cfs_file, hash)
  end
end

When(/^I update the cfs file with name '([^']*)' with fields:$/) do |name, table|
  cfs_file = CfsFile.find_by(name: name)
  cfs_file.update_attributes!(table.hashes.first)
end

Then(/^(\d+) cfs files should have fits attached$/) do |count|
  expect(CfsFile.with_fits.count).to eql(count.to_i)
end

Then(/^I should see a table of cfs files with (\d+) rows?$/) do |count|
  expect(page).to have_selector('#cfs_files')
  within('#cfs_files') do
    expect(page).to have_css('tbody tr', count: count.to_i)
  end
end

When(/^I reset fixity and FITS information for the cfs file named '(.*)'$/) do |name|
  CfsFile.find_by(name: name).reset_fixity_and_fits!
end
