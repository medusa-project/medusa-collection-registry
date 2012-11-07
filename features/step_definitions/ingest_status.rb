Given /^the collection titled '(.*)' has ingest status with fields:$/ do |title, table|
  status = Collection.find_by_title(title).ingest_status
  table.hashes.each do |hash|
    hash.each do |k,v|
      if k != 'date'
        status[k] = v
      else
        status[:date] = Date.parse(v)
      end
    end
  end
  status.save!
end

And /^I fill in ingest status fields:$/ do |table|
  within('#editIngestStatusModal') do
    table.raw.each do |row|
      fill_in(row.first, :with => row.last)
    end
  end
end