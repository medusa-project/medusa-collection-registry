And(/^the cfs file with name '([^']*)' should have fits data matching:$/) do |name, table|
  file = CfsFile.find_by(name: name)
  fits_data = file.fits_data
  table.rows.each do |field, value|
    expect(fits_data.send(field).to_s).to eq(value)
  end
end

