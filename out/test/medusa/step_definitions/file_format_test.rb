And(/^the cfs file with name '([^']*)' should have an associated file format test$/) do |name|
  expect(CfsFile.find_by(name: name).file_format_test).to be_truthy
end

And(/^the cfs file with name '([^']*)' is associated with the file format test with tester email '([^']*)'$/) do |name, email|
  cfs_file = CfsFile.find_by(name: name)
  file_format_test = FileFormatTest.find_by(tester_email: email)
  cfs_file.file_format_test = file_format_test
end

