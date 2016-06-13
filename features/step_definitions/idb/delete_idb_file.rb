When(/^IDB sends an delete request$/) do
  AmqpConnector.connector(:medusa).send_message(AmqpAccrual::Config.incoming_queue('idb'), IdbTestHelper.idb_delete_message)
end

Then(/^there should be an IDB delete delayed job reflecting the delete request$/) do
  message = IdbTestHelper.idb_delete_message
  expect(AmqpAccrual::DeleteJob.find_by(client: 'idb', cfs_file_uuid: message['uuid'])).to be_truthy
end

Given(/^there is a valid IDB delete delayed job$/) do
  idb_file_group = AmqpAccrual::Config.file_group('idb')
  cfs_file = FactoryGirl.create(:cfs_file, cfs_directory_id: idb_file_group.cfs_directory.id, name: 'test.txt')
  File.open(cfs_file.absolute_path, 'w') { |f| f.puts 'Some content' }
  idb_file_group.reload
  @initial_idb_file_count = idb_file_group.total_files
  @idb_file_to_delete = cfs_file
  AmqpAccrual::DeleteJob.create_for('idb', IdbTestHelper.idb_delete_message.merge('uuid' => cfs_file.uuid))
end

When(/^the IDB delete delayed job is run$/) do
  AmqpAccrual::DeleteJob.where(client: 'idb').first.perform
end

Then(/^no IDB file should be deleted$/) do
  expect(AmqpAccrual::Config.file_group('idb').total_files).to eq(@initial_idb_file_count)
end

Then(/^Medusa should have sent an error return message to IDB matching 'Deletion is not allowed'$/) do
  AmqpConnector.connector(:medusa).with_message(AmqpAccrual::Config.outgoing_queue('idb')) do |raw_message|
    message = JSON.parse(raw_message)
    expect(message['operation']).to eq('delete')
    expect(message['status']).to eq('error')
    expect(message['uuid']).to eq(IdbTestHelper.idb_delete_message['uuid'])
    expect(message['error']).to match('Deletion is not allowed')
  end
end