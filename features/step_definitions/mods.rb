Then /^I should see a valid MODS document$/ do
  doc = Nokogiri::XML(page.source)
  schema = Nokogiri::XML::Schema(File.read(File.join(Rails.root, 'schemas', 'mods.xsd')))
  errors = schema.validate(doc)
  errors.should be_empty
end

Then /^I should see MODS fields by css:$/ do |table|
  doc = Nokogiri::XML(page.source)
  table.raw.each do |row|
    selector = row.first
    text = row.last
    nodes = doc.css("mods #{selector}", doc.namespaces)
    nodes.detect { |node| node.text == text }.should be_truthy
  end
end