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