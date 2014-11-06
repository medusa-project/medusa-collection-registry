Then(/^I should receive a file '(.*)' of type '(.*)' matching:$/) do |file_name, mime_type, table|
  expect(page.response_headers['Content-Type']).to eq(mime_type)
  expect(page.response_headers['Content-Disposition']).to match(file_name)
  table.headers.each do |header|
    expect(page).to have_content(header)
  end
end