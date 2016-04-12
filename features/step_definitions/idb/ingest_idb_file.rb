#steps for idb file ingest

When(/^IDB sends an ingest request$/) do
  AmqpConnector.connector(:medusa).send_message(Idb::Config.instance.incoming_queue, IdbTestHelper.idb_ingest_message)
end

And(/^Medusa picks up the IDB ingest request$/) do
  Idb::AmqpReceiver.handle_responses
end

Then(/^there should be an IDB ingest delayed job reflecting the ingest request$/) do
  message = IdbTestHelper.idb_ingest_message
  expect(Idb::IngestJob.find_by(staging_path: message['staging_path'])).to be_truthy
end

Given(/^there is an IDB ingest delayed job$/) do
  IdbTestHelper.stage_content
  Idb::IngestJob.create_for(IdbTestHelper.idb_ingest_message)
end

And(/^there is an IDB file group$/) do
  file_group = FactoryGirl.create(:bit_level_file_group)
  Idb::Config.instance.idb_file_group_id = file_group.id
end

When(/^the IDB ingest delayed job is run$/) do
  Idb::IngestJob.first.perform
end

Then(/^the IDB files should be present in medusa storage$/) do
  expect(Idb::Config.instance.idb_file_group.total_files).to eq(1)
  Idb::Config.instance.idb_cfs_directory.each_file_in_tree do |file|
    expect(file.name).to eq('file.txt')
    expect(File.read(file.absolute_path)).to match('Staging text')
  end
end

And(/^Medusa should have sent a return message to IDB$/) do
  AmqpConnector.connector(:medusa).with_message(Idb::Config.instance.outgoing_queue) do |raw_message|
    message = JSON.parse(raw_message)
    expect(message['operation']).to eq('ingest')
    expect(message['status']).to eq('ok')
    expect(message['staging_path']).to eq(IdbTestHelper.staging_path)
    expect(message['item_root_dir']).to be_truthy
    f = CfsFile.first
    expect(message['medusa_path']).to match(f.relative_path.gsub(/^#{f.cfs_directory.root_cfs_directory.relative_path}\//, ''))
  end
end

