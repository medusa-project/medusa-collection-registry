When(/^IDB sends an delete request$/) do
  AmqpHelper::Connector[:medusa].send_message(AmqpAccrual::Config.incoming_queue('idb'), IdbTestHelper.idb_delete_message)
end

Then(/^there should be an IDB delete delayed job reflecting the delete request$/) do
  message = IdbTestHelper.idb_delete_message
  expect(AmqpAccrual::DeleteJob.find_by(client: 'idb', cfs_file_uuid: message['uuid'])).to be_truthy
end

Given(/^there is a valid IDB delete delayed job$/) do
  idb_file_group = AmqpAccrual::Config.file_group('idb')
  cfs_file = FactoryBot.create(:cfs_file, cfs_directory_id: idb_file_group.cfs_directory.id, name: 'test.txt')
  File.open(cfs_file.absolute_path, 'w') { |f| f.puts 'Some content' }
  idb_file_group.reload
  @initial_idb_file_count = idb_file_group.total_files
  @idb_file_to_delete = cfs_file
  @idb_uuid_to_delete = cfs_file.uuid
  AmqpAccrual::DeleteJob.create_for('idb', IdbTestHelper.idb_delete_message.merge('uuid' => cfs_file.uuid))
end

When(/^the IDB delete delayed job is run$/) do
  AmqpAccrual::DeleteJob.where(client: 'idb').first.perform
end

Then(/^no IDB file should be deleted$/) do
  expect(AmqpAccrual::Config.file_group('idb').total_files).to eq(@initial_idb_file_count)
end

Then(/^Medusa should have sent an error return message to IDB matching '(.*)'$/) do |text|
  AmqpHelper::Connector[:medusa].with_message(AmqpAccrual::Config.outgoing_queue('idb')) do |raw_message|
    message = JSON.parse(raw_message)
    expect(message['operation']).to eq('delete')
    expect(message['status']).to eq('error')
    if @idb_uuid_to_delete.present?
      expect(message['uuid']).to eq(@idb_uuid_to_delete)
    else
      expect(message['uuid']).to eq(IdbTestHelper.idb_delete_message['uuid'])
    end
    expect(message['error']).to match(text)
  end
end

Given(/^there is an IDB delete delayed job for a cfs file in another file group$/) do
  idb_file_group = AmqpAccrual::Config.file_group('idb')
  cfs_file = FactoryBot.create(:cfs_file, name: 'test.txt')
  idb_file_group.reload
  @initial_idb_file_count = idb_file_group.total_files
  @idb_uuid_to_delete = cfs_file.uuid
  AmqpAccrual::DeleteJob.create_for('idb', IdbTestHelper.idb_delete_message.merge('uuid' => cfs_file.uuid))
end

Given(/^there is an IDB delete delayed job for a uuid corresponding to a non\-file object$/) do
  idb_file_group = AmqpAccrual::Config.file_group('idb')
  @initial_idb_file_count = idb_file_group.total_files
  @idb_uuid_to_delete = idb_file_group.uuid
  AmqpAccrual::DeleteJob.create_for('idb', IdbTestHelper.idb_delete_message.merge('uuid' => idb_file_group.uuid))
end

Given(/^there is an IDB delete delayed job for a cfs file that does not exist$/) do
  idb_file_group = AmqpAccrual::Config.file_group('idb')
  @initial_idb_file_count = idb_file_group.total_files
  @idb_uuid_to_delete = IdbTestHelper.idb_delete_message['uuid']
  AmqpAccrual::DeleteJob.create_for('idb', IdbTestHelper.idb_delete_message)
end

Then(/^the IDB file should have been deleted$/) do
  expect(CfsFile.find_by(id: @idb_file_to_delete.id)).to be_nil
  expect(@idb_file_to_delete.exists_on_storage?).to be false
  expect(AmqpAccrual::Config.file_group('idb').total_files).to eq(@initial_idb_file_count - 1)
end

And(/^Medusa should have sent a valid delete return message to IDB$/) do
  AmqpHelper::Connector[:medusa].with_message(AmqpAccrual::Config.outgoing_queue('idb')) do |raw_message|
    message = JSON.parse(raw_message)
    expect(message['operation']).to eq('delete')
    expect(message['status']).to eq('ok')
    expect(message['uuid']).to eq(@idb_uuid_to_delete)
  end
end