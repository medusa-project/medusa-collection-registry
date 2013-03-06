And /^the directory named '(.*)' has bit files with fields:$/ do |name, table|
  directory = Directory.find_by_name(name)
  table.hashes.each do |hash|
    BitFile.create(hash.merge(:directory_id => directory.id))
  end
end

When /^I request JSON for the bit file named '(.*)'$/ do |name|
  visit file_path(BitFile.find_by_name(name), :format => 'json')
end

Given /^the bit file named '(.*)' has FITS xml attached$/ do |name|
  bit_file = BitFile.find_by_name(name)
  bit_file.fits_xml = File.read(File.join(Rails.root, 'features', 'fixtures', 'fits.xml'))
  bit_file.save!
end

Then /^I should be on the view page for the FITS XML for the bit file named '(.*)'$/ do |name|
  current_path.should == view_fits_xml_file_path(BitFile.find_by_name(name), :format => 'xml')
end

Then /^I should be on the create page for the FITS XML for the bit file named '(.*)'$/ do |name|
  current_path.should == create_fits_xml_file_path(BitFile.find_by_name(name))
end

And /^the bit file named '(.*)' should have FITS XML attached$/ do |name|
  BitFile.find_by_name(name).fits_xml.should_not be_nil
end

Given /^the bit file named '(.*)' has been DX ingested$/ do |name|
  bf = BitFile.find_by_name(name)
  bf.dx_ingested = true
  bf.save!
end