require 'fileutils'

Then(/^I should receive a file '([^']*)' of type '([^']*)' matching:$/) do |file_name, mime_type, table|
  begin
    content_type = page.response_headers['Content-Type']
    content_disposition = page.response_headers['Content-Disposition']
    expect(content_type).to eq(mime_type)
    expect(content_disposition).to match(file_name)
  rescue Capybara::NotSupportedByDriverError
    puts 'Unable to test response headers with this javascript driver'
  end
  table.headers.each do |header|
    expect(page).to have_content(header)
  end
end

#This is intended for a javascript driver that is able to allow header inspection
Then(/^I should receive a file '([^']*)' of type '([^']*)'$/) do |file_name, mime_type|
  expect(page.response_headers['Content-Type']).to eq(mime_type)
  expect(page.response_headers['Content-Disposition']).to match(file_name)
end

#This doesn't actually test the mime_type, which we'd want to check from the response headers
# This is intended for use with a selenium that actually does a download
# We can't check the Content-Type header, though we may be able to check the file in other ways
# dispatching on the mime_type.
Then(/^I should have downloaded a file '([^']*)' of type '([^']*)'$/) do |file_name, mime_type|
  expect(File.exist?(File.join(CAPYBARA_DOWNLOAD_DIR, file_name))).to be_truthy
end
