TABLE_IDS = {'file groups' => 'file_groups', 'red flags' => 'red-flags-table',
             'file stats by content type' => 'file_stats_content_type', 'file stats by file extension' => 'file_stats_file_extension',
             'file stats summary' => 'file_stats_summary', 'running virus scans' => 'running_virus_scans',
             'running fits scans' => 'running_fits_scans', 'running initial assessment scans' => 'running_initial_assessment_scans',
             'running ingests' => 'running_ingests'}

def table_selector(key)
  id = TABLE_IDS[key.to_s] || key.gsub(' ', '-')
  "table##{id}"
end

Then(/^I should see the ([^']*) table$/) do |key|
  page.should have_selector(table_selector(key))
end

Then(/^the (.*) table should have (\d+) rows?$/) do |key, count|
  within(table_selector(key)) do
    within('tbody') { expect(all('tr').count).to eq(count.to_i) }
  end
end

And(/^I click on '(.*)' in the ([^']*) table$/) do |link, key|
  within(table_selector(key)) do
    click_on(link)
  end
end

