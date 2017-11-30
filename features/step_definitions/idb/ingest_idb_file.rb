#steps for idb file ingest

When(/^IDB sends an ingest request$/) do
  AmqpHelper::Connector[:medusa].send_message(AmqpAccrual::Config.incoming_queue('idb'), IdbTestHelper.idb_ingest_message)
end

And(/^Medusa picks up the IDB AMQP request$/) do
  AmqpAccrual::Receiver.handle_responses('idb')
end

Then(/^there should be an IDB ingest delayed job reflecting the ingest request$/) do
  message = IdbTestHelper.idb_ingest_message
  expect(AmqpAccrual::IngestJob.find_by(staging_path: message['staging_path'], client: 'idb')).to be_truthy
end

Given(/^there is an IDB ingest delayed job$/) do
  IdbTestHelper.stage_content
  AmqpAccrual::IngestJob.create_for('idb', IdbTestHelper.idb_ingest_message)
end

And(/^there is an IDB file group$/) do
  file_group = FactoryBot.create(:bit_level_file_group)
  AmqpAccrual::Config.set_file_group_id('idb', file_group.id)
end

When(/^the IDB ingest delayed job is run$/) do
  AmqpAccrual::IngestJob.where(client: 'idb').first.perform
end

Then(/^the IDB files should be present in medusa storage$/) do
  expect(AmqpAccrual::Config.file_group('idb').total_files).to eq(1)
  AmqpAccrual::Config.cfs_directory('idb').each_file_in_tree do |file|
    expect(file.name).to eq('file.txt')
    expect(File.read(file.absolute_path)).to match('Staging text')
  end
  file = CfsFile.find_by(name: 'file.txt')
  expect(file).to be_a(CfsFile)
  expect(file.events.where(key: 'amqp_accrual').count).to eq(1)
end

And(/^Medusa should have sent an ingest return message to IDB$/) do
  AmqpHelper::Connector[:medusa].with_message(AmqpAccrual::Config.outgoing_queue('idb')) do |raw_message|
    message = JSON.parse(raw_message)
    expect(message['operation']).to eq('ingest')
    expect(message['status']).to eq('ok')
    expect(message['staging_path']).to eq(IdbTestHelper.staging_path)
    expect(message['item_root_dir']).to be_truthy
    f = CfsFile.first
    expect(message['medusa_path']).to match(f.relative_path.gsub(/^#{f.cfs_directory.root_cfs_directory.relative_path}\//, ''))
  end
end

