Then /^There should be standard default file types$/ do
  ['Derivative Content', 'Master Metadata', 'Other', 'Mixed Content',
   'Master Mixed Content', 'Derivative Mixed Content'].each do |name|
    FileType.find_by(name: name).should_not be_nil
  end
end