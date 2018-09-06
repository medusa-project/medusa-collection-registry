#steps for idb file ingest

When(/^IDB sends an ingest request$/) do
  AmqpHelper::Connector[:medusa].send_message(AmqpAccrual::Config.incoming_queue('idb'), IdbTestHelper.idb_ingest_message)
end

And(/^Medusa picks up the IDB AMQP request$/) do
  AmqpAccrual::Receiver.handle_responses('idb')
end

Then(/^there should be an IDB ingest delayed job reflecting the ingest request$/) do
  message = IdbTestHelper.idb_ingest_message
  expect(find_amqp_ingest_job('idb', message)).to be_truthy
end

def find_amqp_ingest_job(client, message)
  jobs = AmqpAccrual::IngestJob.where(client: client).all
  jobs.detect do |job|
    job.incoming_message == message
  end
end

Given(/^there is an IDB ingest delayed job$/) do
  IdbTestHelper.stage_content(IdbTestHelper.idb_ingest_message)
  AmqpAccrual::IngestJob.create_for('idb', IdbTestHelper.idb_ingest_message)
end

And(/^there is an IDB file group$/) do
  file_group = FactoryBot.create(:bit_level_file_group)
  AmqpAccrual::Config.set_file_group_id('idb', file_group.id)
end

When(/^the IDB ingest delayed job is run$/) do
  AmqpAccrual::IngestJob.where(client: 'idb').first.perform
end

Then(/^the IDB file named '(.*)' should be present in medusa storage$/) do |file_name|
  expect(AmqpAccrual::Config.file_group('idb').total_files).to eq(1)
  AmqpAccrual::Config.cfs_directory('idb').each_file_in_tree do |file|
    expect(file.name).to eq(file_name)
    file_content = file.with_input_io do |io|
      io.read
    end
    expect(file_content).to match('Staging text')
  end
  file = CfsFile.find_by(name: file_name)
  expect(file).to be_a(CfsFile)
  expect(file.events.where(key: 'amqp_accrual').count).to eq(1)
end

And(/^Medusa should have sent an ingest return message to IDB$/) do
  AmqpHelper::Connector[:medusa].with_message(AmqpAccrual::Config.outgoing_queue('idb')) do |raw_message|
    message = JSON.parse(raw_message)
    expect(message['operation']).to eq('ingest')
    expect(message['status']).to eq('ok')
    expect(message['staging_path']).to eq(IdbTestHelper.staging_key(message))
    expect(message['item_root_dir']).to be_truthy
    f = CfsFile.first
    expect(message['medusa_path']).to eq('test_dir/file.txt')
  end
end


When(/^IDB sends an ingest request with new message syntax$/) do
  AmqpHelper::Connector[:medusa].send_message(AmqpAccrual::Config.incoming_queue('idb'), IdbTestHelper.idb_ingest_message_new_syntax)
end

Then(/^there should be an IDB ingest delayed job reflecting the ingest request with new message syntax$/) do
  message = IdbTestHelper.idb_ingest_message_new_syntax
  expect(find_amqp_ingest_job('idb', message)).to be_truthy
end

When(/^there is an IDB ingest delayed job with new message syntax$/) do
  IdbTestHelper.stage_content(IdbTestHelper.idb_ingest_message_new_syntax)
  AmqpAccrual::IngestJob.create_for('idb', IdbTestHelper.idb_ingest_message_new_syntax)
end

And(/^Medusa should have sent an ingest return message to IDB with new message syntax$/) do
  AmqpHelper::Connector[:medusa].with_message(AmqpAccrual::Config.outgoing_queue('idb')) do |raw_message|
    message = JSON.parse(raw_message)
    expect(message['operation']).to eq('ingest')
    expect(message['status']).to eq('ok')
    expect(message['staging_key']).to eq(IdbTestHelper.staging_key(message))
    expect(message['item_root_dir']).to be_truthy
    expect(message['medusa_path']).to eq(IdbTestHelper.idb_ingest_message_new_syntax['target_key'])
    expect(message['medusa_key']).to eq(IdbTestHelper.idb_ingest_message_new_syntax['target_key'])
    expect(CfsFile.find_by(name: 'file.txt')).to be_falsey
    expect(CfsFile.find_by(name: 'content.txt')).to be_truthy
    expect(message['pass_through']['key']).to eq('some value')
  end
end