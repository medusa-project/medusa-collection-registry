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

Then(/^I should receive a file '([^']*)' of type '([^']*)'$/) do |file_name, mime_type|
  expect(page.response_headers['Content-Type']).to eq(mime_type)
  expect(page.response_headers['Content-Disposition']).to match(file_name)
end